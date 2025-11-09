import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/hive_service.dart';
import './models/practice_log.dart';
import './models/question_history.dart';

/// 🧠 PracticeRepository — Handles all Practice-related logic (offline + online)
/// - Saves sessions locally (Hive)
/// - Fetches full practice history
/// - Syncs logs to Firebase when online
/// - Provides activity map for heatmap visualization
class PracticeRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// ----------------------------------------------------------
  /// 💾 Save a new practice session (Offline-first)
  /// ----------------------------------------------------------
  Future<void> savePracticeSession(PracticeLog entry) async {
    try {
      // 🧩 1️⃣ Always save locally in Hive
      await HiveService.addPracticeLog(entry);
      log("🧩 Practice session saved locally: ${entry.topic}");

      // ☁️ 2️⃣ Queue for sync if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        await HiveService.queueForSync('practice_logs', entry.toMap());
        log("📤 Practice session queued for sync (user: ${user.uid})");
      }
    } catch (e, st) {
      log("⚠️ Failed to save practice session: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// 🧾 Get all local practice sessions
  /// ----------------------------------------------------------
  List<PracticeLog> getAllLocalSessions() {
    try {
      return HiveService.getPracticeLogs();
    } catch (e, st) {
      log("⚠️ Failed to get practice logs: $e", stackTrace: st);
      return [];
    }
  }

  /// ----------------------------------------------------------
  /// 📜 Get full question history (optional)
  /// ----------------------------------------------------------
  List<QuestionHistory> getQuestionHistory() {
    try {
      return HiveService.getHistory();
    } catch (e, st) {
      log("⚠️ Failed to get question history: $e", stackTrace: st);
      return [];
    }
  }

  /// ----------------------------------------------------------
  /// 📤 Sync pending practice logs → Firebase (when online)
  /// ----------------------------------------------------------
  Future<void> syncPendingSessions() async {
    final user = _auth.currentUser;
    if (user == null) {
      log("⚠️ User not logged in — skipping practice log sync");
      return;
    }

    try {
      final pending = HiveService.getPendingSyncs()
          .where((item) => item['type'] == 'practice_logs')
          .toList();

      if (pending.isEmpty) {
        log("ℹ️ No pending practice logs to sync");
        return;
      }

      for (final item in pending) {
        final data = Map<String, dynamic>.from(item['data']);
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('practice_sessions')
            .doc(timestamp)
            .set(data, SetOptions(merge: true));

        log("✅ Synced practice session → Firebase (id: $timestamp)");
      }

      log("✅ All pending practice logs synced successfully");
    } catch (e, st) {
      log("⚠️ Failed to sync practice sessions: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// 🔄 SyncData (used by SyncManager)
  /// ----------------------------------------------------------
  Future<void> syncData() async {
    try {
      await syncPendingSessions();
      log("✅ PracticeRepository sync complete.");
    } catch (e, st) {
      log("⚠️ PracticeRepository sync failed: $e", stackTrace: st);
    }
  }

  /// ----------------------------------------------------------
  /// 🗓️ Get Activity Map from Hive (used in heatmap)
  /// ----------------------------------------------------------
  Map<DateTime, int> getActivityMapFromHive() {
    try {
      return HiveService.getActivityMap();
    } catch (e, st) {
      log("⚠️ Failed to load activity map from Hive: $e", stackTrace: st);
      return {};
    }
  }

  /// ----------------------------------------------------------
  /// 🧹 Clear all local data (for reset / logout)
  /// ----------------------------------------------------------
  Future<void> clearAllLocalData() async {
    try {
      await HiveService.clearPracticeLogs();
      log("🧹 Cleared all local practice logs successfully");
    } catch (e, st) {
      log("⚠️ Failed to clear practice logs: $e", stackTrace: st);
    }
  }
}
