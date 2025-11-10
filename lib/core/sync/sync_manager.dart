import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../../features/practice/data/practice_repository.dart';
import '../../features/performance/data/performance_repository.dart';
import '../../features/quiz/data/models/quiz_session_model.dart';
import '../../features/quiz/data/repositories/quiz_repository.dart';
import '../services/hive_service.dart';

/// 🌐 SyncManager — Unified Hybrid Sync System
///
/// Handles:
/// - Background sync between Hive & Firebase
/// - Multi-repository sync (Quiz + Practice + Performance)
/// - Automatic retry when connectivity is restored
/// - Debounced sync runs (prevents repeated triggers)
class SyncManager {
  // 🧩 Singleton instance
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  // ---------------------------------------------------------------------------
  // 🧱 Dependencies
  // ---------------------------------------------------------------------------
  final QuizRepository quizRepository = QuizRepository();
  final PracticeRepository practiceRepository = PracticeRepository();
  final PerformanceRepository performanceRepository = PerformanceRepository();

  StreamSubscription<ConnectivityResult>? _connectivitySub;

  bool _isSyncing = false;
  DateTime _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(0);

  // ---------------------------------------------------------------------------
  // 🚀 Start monitoring connectivity
  // ---------------------------------------------------------------------------
  Future<void> start() async {
    // ✅ Wait for HiveService initialization before starting sync
    int attempts = 0;
    while (!HiveService.isBoxOpen('practice_logs') && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;
    }

    log("🔄 SyncManager started — monitoring connectivity...");

    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      if (result == ConnectivityResult.none) {
        log("📴 Connection lost — pausing sync.");
        return;
      }

      // Debounce: prevent rapid consecutive triggers
      final now = DateTime.now();
      if (now.difference(_lastSyncTime).inSeconds < 10) return;
      _lastSyncTime = now;

      log("🌐 Internet available — triggering background sync...");
      await syncAll();
    });
  }

  // ---------------------------------------------------------------------------
  // 🧹 Stop listening (called on app close)
  // ---------------------------------------------------------------------------
  void stop() {
    _connectivitySub?.cancel();
    log("🛑 SyncManager stopped listening to connectivity.");
  }

  // ---------------------------------------------------------------------------
  // 🔁 Perform full background sync
  // ---------------------------------------------------------------------------
  Future<void> syncAll() async {
    if (_isSyncing) {
      log("⚙️ SyncManager: Sync already running, skipping duplicate.");
      return;
    }

    _isSyncing = true;
    log("🚀 SyncManager: Starting full hybrid sync...");

    try {
      // 1️⃣ Sync offline quiz sessions (Hive → Firebase)
      await _syncPendingQuizSessions();

      // 2️⃣ Sync additional repositories in parallel
      await Future.wait([
        practiceRepository.syncData(),
        performanceRepository.syncData(),
      ]);

      log("✅ SyncManager: All data synchronized successfully.");
    } catch (e, st) {
      log("❌ SyncManager.syncAll failed: $e", stackTrace: st);
    } finally {
      _isSyncing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🧠 Sync pending offline quiz sessions (Hive → Firebase)
  // ---------------------------------------------------------------------------
  Future<void> _syncPendingQuizSessions() async {
    try {
      if (!HiveService.isBoxOpen('practice_logs')) {
        log("⚠️ Hive box 'practice_logs' not open yet — skipping sync.");
        return;
      }

      final box = Hive.box('practice_logs');
      final sessions = box.values.toList();

      if (sessions.isEmpty) {
        log("ℹ️ No pending quiz sessions to sync.");
        return;
      }

      int success = 0;
      int failed = 0;

      for (final raw in sessions) {
        try {
          // Defensive: convert any object to map safely
          final map = raw is Map ? Map<String, dynamic>.from(raw) : raw.toMap();
          final session = QuizSessionModel.fromMap(map);

          // Only sync ranked (daily) quiz sessions
          if (session.category.toLowerCase().contains('ranked')) {
            await quizRepository.saveRankedResult(session);
            success++;
            await _deleteSyncedSession(box, raw);
          }
        } catch (e) {
          failed++;
          log("⚠️ Sync failed for one session: $e");
        }
      }

      log("✅ Synced $success sessions, $failed failed.");
    } catch (e, st) {
      log("❌ _syncPendingQuizSessions failed: $e", stackTrace: st);
    }
  }

  // ---------------------------------------------------------------------------
  // 🧹 Delete successfully synced Hive entries
  // ---------------------------------------------------------------------------
  Future<void> _deleteSyncedSession(Box box, dynamic raw) async {
    try {
      final key = box.keys.firstWhere(
        (k) => box.get(k) == raw,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
        log("🧹 Deleted synced Hive entry (key: $key)");
      }
    } catch (e) {
      log("⚠️ Cleanup failed: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // 🕓 Manual trigger (for AppInitializer or HomeScreen refresh)
  // ---------------------------------------------------------------------------
  Future<void> syncPendingSessions() async {
    log("🔁 Manual sync trigger received...");
    await syncAll();
  }
}
