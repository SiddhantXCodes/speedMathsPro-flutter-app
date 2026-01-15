// lib/providers/performance_provider.dart
import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class PerformanceProvider extends ChangeNotifier {
  // --------------------------------------------------------------------------
  // CONSTRUCTOR (NO AUTO INIT)
  // --------------------------------------------------------------------------
  PerformanceProvider();

  // --------------------------------------------------------------------------
  // STATE
  // --------------------------------------------------------------------------
  Map<DateTime, int> _dailyScores = {}; // ranked trend only (date → score)

  bool _initialized = false;
  bool get initialized => _initialized;

  int? _bestScore;

  // --------------------------------------------------------------------------
  // GETTERS
  // --------------------------------------------------------------------------
  Map<DateTime, int> get dailyScores => _dailyScores;

  bool get loading => !_initialized;

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
  // INIT — CALLED FROM main.dart
  // --------------------------------------------------------------------------
  Future<void> init() async {
    if (_initialized) return;

    await reloadAll();
    _initialized = true;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // LOCAL RANKED SCORES
  // --------------------------------------------------------------------------
  Future<void> loadFromLocal({bool force = false}) async {
    try {
      final ranked = HiveService.getRankedScores();

      _dailyScores = {
        for (final e in ranked)
          DateTime(e.date.year, e.date.month, e.date.day): e.score,
      };

      if (ranked.isEmpty) {
        _bestScore = 0;
      } else {
        _bestScore =
            ranked.map((e) => e.score).reduce((a, b) => a > b ? a : b);
      }
    } catch (e) {
      debugPrint("⚠️ loadFromLocal error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // RELOAD EVERYTHING
  // --------------------------------------------------------------------------
  Future<void> reloadAll() async {
    try {
      await loadFromLocal();
    } catch (e) {
      debugPrint("⚠️ reloadAll error: $e");
    }
  }

  // --------------------------------------------------------------------------
  // RESET
  // --------------------------------------------------------------------------
  Future<void> resetAll() async {
    _dailyScores.clear();
    _bestScore = null;

    try {
      await HiveService.clearRankedScores();
    } catch (e) {
      debugPrint("⚠️ resetAll error: $e");
    }

    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // TEST SUPPORT
  // --------------------------------------------------------------------------
  void testMarkInitialized() {
    _initialized = true;
    notifyListeners();
  }
}
