import 'package:flutter/material.dart';
import '../../services/sync_manager.dart';
import 'load_home_data.dart';
import '../performance/performance_provider.dart';
import '../practice/practice_log_provider.dart';

/// 🏠 HomeProvider — coordinates data loading + syncing for HomeScreen
class HomeProvider extends ChangeNotifier {
  final PerformanceProvider performance;
  final PracticeLogProvider practice;
  final LoadHomeData loadHomeData;
  final SyncManager syncManager;

  HomeProvider({
    required this.performance,
    required this.practice,
    required this.loadHomeData,
    required this.syncManager,
  });

  bool _loading = false;
  bool get loading => _loading;

  /// 🔁 Refreshes all home data (local + online)
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    try {
      // 🧠 1️⃣ Reload local performance & practice stats
      await performance.loadFromLocal(forceReload: true);

      // ⚙️ 2️⃣ Execute domain usecase (home data prefetch)
      await loadHomeData.execute();

      // ☁️ 3️⃣ Sync with Firebase (ranked + practice + performance)
      await syncManager.syncAll();

      debugPrint("✅ Home data refresh and sync complete.");
    } catch (e, st) {
      debugPrint("⚠️ HomeProvider.refresh() failed: $e\n$st");
    }

    _loading = false;
    notifyListeners();
  }
}
