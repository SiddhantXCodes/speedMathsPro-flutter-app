import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import '../../models/daily_score.dart';
import 'performance_repository.dart';
import 'package:speedmaths_pro/models/streak_data.dart';

/// 📊 PerformanceProvider —
/// Central ViewModel for performance stats, leaderboard, streaks & trends.
class PerformanceProvider extends ChangeNotifier {
  final PerformanceRepository _repository = PerformanceRepository();

  // --------------------------------------------------------------------------
  // 🧱 State fields
  // --------------------------------------------------------------------------
  Map<DateTime, int> _dailyScores = {};
  List<Map<String, dynamic>> _trendData = [];
  Map<String, dynamic>? _leaderboardData;

  bool _loaded = false;
  bool _isLoadingLeaderboard = false;

  int _currentStreak = 0;
  int? _todayRank;
  int? _allTimeRank;
  int? _bestScore;

  // --------------------------------------------------------------------------
  // 🧭 Getters
  // --------------------------------------------------------------------------
  Map<DateTime, int> get dailyScores => _dailyScores;
  List<Map<String, dynamic>> get trendData => _trendData;
  Map<String, dynamic>? get leaderboardData => _leaderboardData;

  bool get loaded => _loaded;
  bool get isLoadingLeaderboard => _isLoadingLeaderboard;

  int get currentStreak => _currentStreak;
  int? get todayRank => _todayRank;
  int? get allTimeRank => _allTimeRank;
  int? get bestScore => _bestScore;
  bool get loading => _isLoadingLeaderboard;

  // --------------------------------------------------------------------------
  // 🧠 Initialize or reload from Hive
  // --------------------------------------------------------------------------
  Future<void> loadFromLocal({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;

    try {
      final allScores = await _repository.fetchRankedQuizTrend(); // Hive data
      _dailyScores = {
        for (final item in allScores)
          DateTime(item['date'].year, item['date'].month, item['date'].day):
              item['score'],
      };

      _loaded = true;
      await fetchCurrentStreak();
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Failed to load local performance data: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🏅 Fetch leaderboard data (Firebase + Cache)
  // --------------------------------------------------------------------------
  Future<void> fetchLeaderboardHeader() async {
    if (_isLoadingLeaderboard) return;
    _isLoadingLeaderboard = true;
    notifyListeners();

    try {
      _leaderboardData = await _repository.fetchLeaderboardHeader();

      _todayRank = _leaderboardData?['todayRank'];
      _allTimeRank = _leaderboardData?['allTimeRank'];
      _bestScore = _leaderboardData?['bestScore'];
    } catch (e) {
      debugPrint("⚠️ Failed to fetch leaderboard header: $e");
    } finally {
      _isLoadingLeaderboard = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // 📈 Refresh ranked quiz trend (last 7 days)
  // --------------------------------------------------------------------------
  Future<void> refreshTrend() async {
    try {
      _trendData = await _repository.fetchRankedQuizTrend();
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Failed to fetch ranked quiz trend: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 💾 Add today’s ranked score (offline-first)
  // --------------------------------------------------------------------------
  Future<void> addTodayScore(int score) async {
    try {
      final today = DateTime.now();
      final safeScore = score < 0 ? 0 : score;
      final dailyScore = DailyScore(date: today, score: safeScore);

      await _repository.saveDailyScore(dailyScore);
      _dailyScores[DateTime(today.year, today.month, today.day)] = safeScore;

      await _updateStreak();

      // 🏆 Update best score locally
      if (_bestScore == null || safeScore > (_bestScore ?? 0)) {
        _bestScore = safeScore;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Failed to add today's score: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🔥 Fetch current streak (used by TopBar)
  // --------------------------------------------------------------------------
  Future<int> fetchCurrentStreak() async {
    try {
      final streak = HiveService.getStreak();
      _currentStreak = streak?.currentStreak ?? 0;
      notifyListeners();
      return _currentStreak;
    } catch (e) {
      debugPrint("⚠️ Failed to fetch current streak: $e");
      return _currentStreak;
    }
  }

  // --------------------------------------------------------------------------
  // ✅ Helper — Check if user already played today's ranked quiz
  // --------------------------------------------------------------------------
  bool hasPlayedToday() {
    try {
      final streak = HiveService.getStreak();
      if (streak == null) return false;

      final last = _normalize(streak.lastActive);
      final today = _normalize(DateTime.now());
      return last == today;
    } catch (e) {
      debugPrint("⚠️ hasPlayedToday check failed: $e");
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // 🔄 Update streak after completing a ranked quiz
  // --------------------------------------------------------------------------
  Future<void> _updateStreak() async {
    try {
      final today = _normalize(DateTime.now());
      final streak = HiveService.getStreak();

      if (streak == null) {
        final newStreak = StreakData(currentStreak: 1, lastActive: today);
        await HiveService.saveStreak(newStreak);
        _currentStreak = 1;
        notifyListeners();
        return;
      }

      final last = _normalize(streak.lastActive);
      final diff = today.difference(last).inDays;

      if (diff == 1) {
        final updated = StreakData(
          currentStreak: streak.currentStreak + 1,
          lastActive: today,
        );
        await HiveService.saveStreak(updated);
        _currentStreak = updated.currentStreak;
      } else if (diff > 1) {
        final reset = StreakData(currentStreak: 1, lastActive: today);
        await HiveService.saveStreak(reset);
        _currentStreak = 1;
      } else {
        _currentStreak = streak.currentStreak;
      }

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Failed to update streak: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🧩 Normalize date (remove time)
  // --------------------------------------------------------------------------
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // --------------------------------------------------------------------------
  // 📊 Weekly Average (last 7 days)
  // --------------------------------------------------------------------------
  int get weeklyAverage {
    if (_dailyScores.isEmpty) return 0;

    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final d = now.subtract(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    final scores = last7.map((d) => _dailyScores[d] ?? 0).where((s) => s > 0);
    if (scores.isEmpty) return 0;

    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return avg.round();
  }

  // --------------------------------------------------------------------------
  // 🧾 Fetch online attempts (for history screen)
  // --------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchOnlineAttempts({
    int limit = 200,
  }) async {
    try {
      return await _repository.fetchOnlineAttempts(limit: limit);
    } catch (e) {
      debugPrint("⚠️ fetchOnlineAttempts failed: $e");
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // 🔁 Unified reload (for HomeScreen refresh)
  // --------------------------------------------------------------------------
  Future<void> reloadAll() async {
    try {
      await Future.wait([
        loadFromLocal(forceReload: true),
        fetchLeaderboardHeader(),
        fetchCurrentStreak(),
      ]);
      debugPrint("✅ PerformanceProvider: all data reloaded successfully!");
    } catch (e) {
      debugPrint("⚠️ reloadAll failed: $e");
    }
  }

  // --------------------------------------------------------------------------
  // 🧹 Clear all local ranked quiz data
  // --------------------------------------------------------------------------
  Future<void> clearAll() async {
    try {
      await _repository.clearAllLocalData();
      _dailyScores.clear();
      _leaderboardData = null;
      _trendData.clear();
      _loaded = false;
      _currentStreak = 0;
      _todayRank = null;
      _allTimeRank = null;
      _bestScore = null;
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ Failed to clear local performance data: $e");
    }
  }
}
