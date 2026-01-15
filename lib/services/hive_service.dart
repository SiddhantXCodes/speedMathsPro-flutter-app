// lib/services/hive_service.dart

import 'package:hive/hive.dart';
import 'hive_boxes.dart';

// Models
import '../models/practice_log.dart';
import '../models/question_history.dart';
import '../models/streak_data.dart';

import '../models/daily_score.dart';

import '../models/user_settings.dart';
import '../models/practice_mode.dart';

class HiveService {
  // ---------------------------------------------------------------------------
  // Utils
  // ---------------------------------------------------------------------------
  static String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  static Future<Box<T>> _safeBox<T>(String name) async {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox<T>(name);
    }
    return Hive.box<T>(name);
  }

  // ===========================================================================
  // ⭐ NEW QUIZ SYSTEM — STRICTLY SEPARATED SCORE BOXES
  // ===========================================================================

  // ---------------- PRACTICE ----------------
  static Future<void> savePracticeScore(DailyScore score) async {
    final box = await _safeBox<DailyScore>('practice_scores');
    await box.add(score);
  }

  static List<DailyScore> getPracticeScores() {
    if (!Hive.isBoxOpen('practice_scores')) return [];
    return Hive.box<DailyScore>('practice_scores')
        .values
        .toList()
        .reversed
        .toList();
  }

  // ---------------- RANKED (ONE PER DAY) ----------------
  static Future<void> saveRankedScore(DailyScore score) async {
    final box = await _safeBox<DailyScore>('ranked_scores');
    final key = _dateKey(score.date);

    // overwrite → ensures ONE attempt per day
    await box.put(key, score);

    // ranked contributes to heatmap
    await _incrementActivityForDate(score.date, 1);
  }

  static List<DailyScore> getRankedScores() {
    if (!Hive.isBoxOpen('ranked_scores')) return [];
    return Hive.box<DailyScore>('ranked_scores')
        .values
        .toList()
        .reversed
        .toList();
  }

  /// 🧠 Has user already played ranked today?
  static Future<bool> hasRankedAttemptToday() async {
    final box = await _safeBox<DailyScore>('ranked_scores');
    final todayKey = _dateKey(DateTime.now());
    return box.containsKey(todayKey);
  }

  // ---------------- MIXED ----------------
  static Future<void> saveMixedScore(DailyScore score) async {
    final box = await _safeBox<DailyScore>('mixed_scores');
    await box.add(score);
  }

  static List<DailyScore> getMixedScores() {
    if (!Hive.isBoxOpen('mixed_scores')) return [];
    return Hive.box<DailyScore>('mixed_scores')
        .values
        .toList()
        .reversed
        .toList();
  }

  // ---------------- TOPIC-BASED ----------------
  static Future<void> saveTopicScore(
    PracticeMode mode,
    DailyScore score,
  ) async {
    final box = await _safeBox<Map>('topic_scores');
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await box.put(id, {
      'id': id,
      'mode': mode.name,
      'date': _dateKey(score.date),
      'score': score.score,
      'timeTakenSeconds': score.timeTakenSeconds,
    });
  }

  static List<DailyScore> getTopicScores(PracticeMode mode) {
    if (!Hive.isBoxOpen('topic_scores')) return [];

    final box = Hive.box<Map>('topic_scores');
    final out = <DailyScore>[];

    for (final raw in box.values) {
      try {
        final m = Map<String, dynamic>.from(raw);
        if (m['mode'] != mode.name) continue;

        final p = (m['date'] as String).split('-');
        final date = DateTime(
          int.parse(p[0]),
          int.parse(p[1]),
          int.parse(p[2]),
        );

        out.add(
          DailyScore(
            date: date,
            score: (m['score'] as num).toInt(),
            timeTakenSeconds: (m['timeTakenSeconds'] as num).toInt(),
          ),
        );
      } catch (_) {}
    }

    return out.reversed.toList();
  }

  // ===========================================================================
  // OLD DAILY SCORE SYSTEM (for heatmap + performance)
  // ===========================================================================
  static Future<void> addDailyScore(DailyScore score) async {
    final box = await _safeBox<DailyScore>('daily_scores');
    await box.put(_dateKey(score.date), score);
  }

  static List<DailyScore> getAllDailyScores() {
    if (!Hive.isBoxOpen('daily_scores')) return [];
    return Hive.box<DailyScore>('daily_scores').values.toList();
  }

  // ===========================================================================
  // PRACTICE LOGS
  // ===========================================================================
  static Future<void> addPracticeLog(PracticeLog log) async {
    final box = HiveBoxes.practiceLogBox;
    await box.add(log);
    await _incrementActivityForDate(log.date, 1);
  }

  static List<PracticeLog> getPracticeLogs() {
    if (!Hive.isBoxOpen('practice_logs')) return [];
    return HiveBoxes.practiceLogBox.values.toList();
  }

  // ===========================================================================
  // QUESTION HISTORY
  // ===========================================================================
  static Future<void> addQuestion(QuestionHistory q) async {
    HiveBoxes.questionHistoryBox.add(q);
  }

  static List<QuestionHistory> getHistory() {
    if (!Hive.isBoxOpen('question_history')) return [];
    return HiveBoxes.questionHistoryBox.values.toList();
  }

  // ===========================================================================
  // USER / STREAK / SETTINGS
  // ===========================================================================
  static Future<void> saveStreak(StreakData data) async {
    final box = await _safeBox<StreakData>('streak_data');
    await box.put('streak', data);
  }

  static StreakData? getStreak() {
    if (!Hive.isBoxOpen('streak_data')) return null;
    return Hive.box<StreakData>('streak_data').get('streak');
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final box = await _safeBox<UserSettings>('user_settings');
    await box.put('settings', settings);
  }

  static UserSettings? getSettings() {
    if (!Hive.isBoxOpen('user_settings')) return null;
    return Hive.box<UserSettings>('user_settings').get('settings');
  }


  // ✅ ADD THIS METHOD (FIXES YOUR ERROR)
  static Future<void> clearRankedScores() async {
    final box = await _safeBox<DailyScore>('ranked_scores');
    await box.clear();
  }
// ===========================================================================
// PRACTICE LOGS — CLEAR
// ===========================================================================
static Future<void> clearPracticeLogs() async {
  if (!Hive.isBoxOpen('practice_logs')) {
    await Hive.openBox<PracticeLog>('practice_logs');
  }

  final box = Hive.box<PracticeLog>('practice_logs');
  await box.clear();

  // Also clear activity map (heatmap reset for practice)
  if (Hive.isBoxOpen('activity_data')) {
    await Hive.box<Map>('activity_data').delete('activity');
  }
}


  // ===========================================================================
  // ACTIVITY MAP (HEATMAP)
  // ===========================================================================
  static Future<void> _incrementActivityForDate(DateTime d, int by) async {
    final box = await _safeBox<Map>('activity_data');
    final raw = box.get('activity');
    final data = raw != null ? Map<String, dynamic>.from(raw) : {};

    final k = _dateKey(d);
    data[k] = (data[k] ?? 0) + by;

    await box.put('activity', data);
  }

  static Map<DateTime, int> getActivityMap() {
    if (!Hive.isBoxOpen('activity_data')) return {};
    final raw = Hive.box<Map>('activity_data').get('activity');
    if (raw == null) return {};

    final output = <DateTime, int>{};
    Map<String, dynamic>.from(raw).forEach((k, v) {
      try {
        final p = k.split('-');
        output[DateTime(
          int.parse(p[0]),
          int.parse(p[1]),
          int.parse(p[2]),
        )] = (v as num).toInt();
      } catch (_) {}
    });
    return output;
  }

  // ===========================================================================
  // SYNC QUEUE
  // ===========================================================================
  static Future<void> queueForSync(
    String type,
    Map<String, dynamic> data,
  ) async {
    final box = await _safeBox<Map>('sync_queue');
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, {'id': id, 'type': type, 'data': data});
  }

  // ===========================================================================
  // CLEAR ALL (LOGOUT / RESET)
  // ===========================================================================
  static Future<void> clearAllOfflineData() async {
    await HiveBoxes.practiceLogBox.clear();
    await HiveBoxes.questionHistoryBox.clear();
    await HiveBoxes.dailyScoreBox.clear();

    await (await _safeBox<Map>('activity_data')).clear();
    await (await _safeBox<Map>('sync_queue')).clear();

    await (await _safeBox<DailyScore>('practice_scores')).clear();
    await (await _safeBox<DailyScore>('mixed_scores')).clear();
    await (await _safeBox<DailyScore>('ranked_scores')).clear();
  }
}
