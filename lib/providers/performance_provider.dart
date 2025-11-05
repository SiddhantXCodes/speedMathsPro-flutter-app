import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceProvider extends ChangeNotifier {
  final Map<DateTime, int> _dailyScores = {}; // date → score
  bool _loaded = false;

  Map<DateTime, int> get dailyScores => _dailyScores;
  bool get loaded => _loaded;

  Future<void> loadFromStorage() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('daily_score_'));
    for (final k in keys) {
      final dateStr = k.replaceFirst('daily_score_', '');
      final score = prefs.getInt(k) ?? 0;
      final date = DateTime.tryParse(dateStr);
      if (date != null) _dailyScores[date] = score;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> addTodayScore(int score) async {
    final today = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final key = 'daily_score_${today.toIso8601String().substring(0, 10)}';
    await prefs.setInt(key, score);
    _dailyScores[today] = score;
    notifyListeners();
  }

  /// Get scores of the last 7 days
  List<int> getLast7DaysScores() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    return days.map((d) {
      final key = DateTime(d.year, d.month, d.day);
      return _dailyScores.entries
              .firstWhere(
                (e) => _sameDate(e.key, key),
                orElse: () => MapEntry(key, 0),
              )
              .value ??
          0;
    }).toList();
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
