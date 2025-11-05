import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PracticeLogProvider extends ChangeNotifier {
  Map<DateTime, Map<String, dynamic>> _logs = {}; // date → details

  Map<DateTime, Map<String, dynamic>> get logs => _logs;

  PracticeLogProvider() {
    _loadLogs();
  }

  // ----------------------------------------
  // Load logs from SharedPreferences
  // ----------------------------------------
  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('practice_logs');
    if (rawData != null && rawData.isNotEmpty) {
      final decoded = jsonDecode(rawData) as Map<String, dynamic>;
      _logs = decoded.map((key, value) {
        final date = DateTime.parse(key);
        return MapEntry(date, Map<String, dynamic>.from(value));
      });
    } else {
      _logs = {};
    }
    notifyListeners();
  }

  // ----------------------------------------
  // Add new session (called after each quiz)
  // ----------------------------------------
  Future<void> addSession({
    required String topic,
    required int score,
    required int total,
    required int timeSpentSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    // Create or update existing record
    final current =
        _logs[dateKey] ??
        {
          'sessions': 0,
          'topics': <String>[],
          'totalScore': 0,
          'totalQuestions': 0,
          'timeSpent': 0,
        };

    current['sessions'] += 1;
    current['topics'].add(topic);
    current['totalScore'] += score;
    current['totalQuestions'] += total;
    current['timeSpent'] += timeSpentSeconds;

    _logs[dateKey] = current;

    // Save to local storage
    final encoded = _logs.map(
      (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await prefs.setString('practice_logs', jsonEncode(encoded));

    notifyListeners();
  }

  // ----------------------------------------
  // Get intensity map for HeatmapSection
  // ----------------------------------------
  Map<DateTime, int> getActivityMap() {
    return _logs.map((date, data) {
      final sessions = data['sessions'] ?? 0;
      return MapEntry(date, sessions.clamp(0, 5));
    });
  }

  // ----------------------------------------
  // Get details for a specific day
  // ----------------------------------------
  Map<String, dynamic>? getDaySummary(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _logs[key];
  }

  // Clear all logs (for testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('practice_logs');
    _logs.clear();
    notifyListeners();
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _logs.map(
      (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await prefs.setString('practice_logs', jsonEncode(encoded));
  }

  Future<void> removeSession(DateTime date) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    _logs.remove(key);
    await _saveLogs();
    notifyListeners();
  }
}
