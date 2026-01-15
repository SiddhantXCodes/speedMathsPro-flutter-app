// lib/providers/practice_log_provider.dart

import 'package:flutter/material.dart';
import '../models/practice_log.dart';
import '../features/practice/practice_repository.dart';

class PracticeLogProvider extends ChangeNotifier {
  final PracticeRepository _repository;

  List<PracticeLog> _logs = [];
  List<PracticeLog> get logs => _logs;

  bool _initialized = false;
  bool get initialized => _initialized;

  Map<DateTime, int> _activityMap = {};
  Map<DateTime, int> get activityMap => _activityMap;

  // --------------------------------------------------------------
  // CONSTRUCTOR (NO AUTO INIT)
  // --------------------------------------------------------------
  PracticeLogProvider() : _repository = PracticeRepository();

  // --------------------------------------------------------------
  // PUBLIC INIT (CALLED FROM main.dart)
  // --------------------------------------------------------------
  Future<void> init() async {
    if (_initialized) return;

    await loadLogs();
    _initialized = true;
    notifyListeners();
  }

  // --------------------------------------------------------------
  // LOAD ALL LOGS (Hive)
  // --------------------------------------------------------------
  Future<void> loadLogs() async {
    _logs = _repository.getAllLocalSessions();
    _activityMap = _repository.getActivityMapFromHive();
  }

  // --------------------------------------------------------------
  // ADD PRACTICE SESSION
  // --------------------------------------------------------------
  Future<void> addSession({
    required String topic,
    required String category,
    required int correct,
    required int incorrect,
    required int score,
    required int total,
    required double avgTime,
    required int timeSpentSeconds,
    List<Map<String, dynamic>>? questions,
    Map<int, String>? userAnswers,
  }) async {
    final log = PracticeLog(
      date: DateTime.now(),
      topic: topic,
      category: category,
      correct: correct,
      incorrect: incorrect,
      score: score,
      total: total,
      avgTime: avgTime,
      timeSpentSeconds: timeSpentSeconds,
      questions: questions ?? [],
      userAnswers: userAnswers ?? {},
    );

    await _repository.savePracticeSession(log);

    _logs.add(log);

    final day = DateTime(log.date.year, log.date.month, log.date.day);
    _activityMap[day] = (_activityMap[day] ?? 0) + 1;

    notifyListeners();
  }

  // --------------------------------------------------------------
  // CLEAR ALL PRACTICE DATA
  // --------------------------------------------------------------
  Future<void> clearAll() async {
    await _repository.clearAllLocalData();
    _logs.clear();
    _activityMap.clear();
    notifyListeners();
  }
  // --------------------------------------------------------------
// UNIFIED HISTORY LIST (USED BY ATTEMPTS / HISTORY SCREENS)
// --------------------------------------------------------------
List<Map<String, dynamic>> getAllSessions() {
  return _logs.map((log) {
    return {
      'source': 'offline',
      'date': log.date,
      'topic': log.topic,
      'category': log.category,
      'correct': log.correct,
      'incorrect': log.incorrect,
      'total': log.total,
      'score': log.score,
      'timeSpentSeconds': log.timeSpentSeconds,
      'questions': log.questions,
      'userAnswers': log.userAnswers,
      'raw': log,
    };
  }).toList();
}

}
