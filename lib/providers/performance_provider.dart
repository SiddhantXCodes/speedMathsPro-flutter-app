// lib/providers/performance_provider.dart

import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../features/performance/performance_repository.dart';

class PerformanceProvider extends ChangeNotifier {
  late final PerformanceRepository _repository;

  // --------------------------------------------------------------------------
  // NORMAL CONSTRUCTOR
  // --------------------------------------------------------------------------
  PerformanceProvider() {
    _repository = PerformanceRepository();
    _init();
  }

  // --------------------------------------------------------------------------
  // TEST CONSTRUCTOR
  // --------------------------------------------------------------------------
  PerformanceProvider.test(PerformanceRepository mockRepo) {
    _repository = mockRepo;
    initialized = true;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // STATE
  // --------------------------------------------------------------------------
  Map<DateTime, int> _dailyScores = {}; // ranked trend only (date → score)
  Map<String, dynamic>? _leaderboardData;

  bool initialized = false;
  bool _isLoadingLeaderboard = false;

  int _currentStreak = 0;
  int? _todayRank;
  int? _allTimeRank;
  int? _bestScore;

  // --------------------------------------------------------------------------
  // GETTERS
  // --------------------------------------------------------------------------
  Map<DateTime, int> get dailyScores => _dailyScores;

  Map<String, dynamic>? get leaderboardData => _leaderboardData;

  bool get isLoadingLeaderboard => _isLoadingLeaderboard;
  bool get loading => !initialized;

  int get currentStreak => _currentStreak;

  int? get todayRank => _todayRank;
  int? get allTimeRank => _allTimeRank;
  int? get bestScore => _bestScore;

  /// Weekly average from ranked_scores only
  int get weeklyAverage {
    if (_dailyScores.isEmpty) return 0;

    final now = DateTime.now();

    final recent = List.generate(7, (i) {
      final d = now.subtract(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

    final used = recent
        .map((d) => _dailyScores[d] ?? 0)
        .where((s) => s > 0)
        .toList();

    if (used.isEmpty) return 0;

    return (used.reduce((a, b) => a + b) / used.length).round();
  }

  // --------------------------------------------------------------------------
  // INIT
  // --------------------------------------------------------------------------
  Future<void> _init() async {
    await reloadAll();
    initialized = true;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // LOCAL RANKED SCORES — NEW SYSTEM
  // --------------------------------------------------------------------------
  Future<void> loadFromLocal({bool force = false}) async {
    try {
      // Read from new Hive box: ranked_scores
      final ranked = HiveService.getRankedScores();

      _dailyScores = {
        for (final e in ranked)
          DateTime(e.date.year, e.date.month, e.date.day): e.score,
      };

      // Best ranked score (local)
      if (ranked.isEmpty) {
        _bestScore = 0;
      } else {
        _bestScore = ranked.map((e) => e.score).reduce((a, b) => a > b ? a : b);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ loadFromLocal error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // LEADERBOARD HEADER — from Firebase
  // --------------------------------------------------------------------------
  Future<void> fetchLeaderboardHeader() async {
    if (_isLoadingLeaderboard) return;

    _isLoadingLeaderboard = true;
    notifyListeners();

    try {
      _leaderboardData = await _repository.fetchLeaderboardHeader();

      _todayRank = _leaderboardData?['todayRank'];
      _allTimeRank = _leaderboardData?['allTimeRank'];

      // Firebase bestScore overrides local best score if available
      final fbBest = _leaderboardData?['bestScore'];
      if (fbBest != null) {
        _bestScore = fbBest;
      }

      _currentStreak = _leaderboardData?['currentStreak'] ?? 0;
    } catch (e) {
      debugPrint("⚠️ Leaderboard fetch error: $e");
    }

    _isLoadingLeaderboard = false;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // ONLINE RANKED ATTEMPT HISTORY
  // --------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchOnlineAttempts({
    int limit = 200,
  }) async {
    try {
      return await _repository.fetchOnlineAttempts(limit: limit);
    } catch (_) {
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // RELOAD EVERYTHING
  // --------------------------------------------------------------------------
  Future<void> reloadAll() async {
    try {
      await loadFromLocal();
      await fetchLeaderboardHeader();
      notifyListeners();
    } catch (e) {
      debugPrint("⚠️ reloadAll error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // RESET
  // --------------------------------------------------------------------------
  Future<void> resetAll() async {
    _dailyScores.clear();
    _leaderboardData = null;

    _currentStreak = 0;
    _todayRank = null;
    _allTimeRank = null;
    _bestScore = null;

    try {
      await HiveService.clearDailyScores();
    } catch (e) {
      debugPrint("⚠️ resetAll error: $e");
    }

    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // TEST SUPPORT
  // --------------------------------------------------------------------------
  void testMarkInitialized() {
    initialized = true;
    notifyListeners();
  }
}
