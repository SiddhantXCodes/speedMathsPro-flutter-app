// lib/services/hive_boxes.dart

import 'package:hive_flutter/hive_flutter.dart';

// 🧩 Local user (offline identity)
import '../providers/local_user_provider.dart';

// 🧩 Core models
import '../models/user_settings.dart';

// 🧩 Feature models
import '../models/practice_log.dart';
import '../models/question_history.dart';
import '../models/daily_score.dart';
import '../models/streak_data.dart';

/// 🚀 Centralized Hive initialization
/// Offline-first, no-auth architecture
class HiveBoxes {
  // ===========================================================================
  // INIT
  // ===========================================================================
  static Future<void> init() async {
    await Hive.initFlutter();
    registerAdapters();
    await openEssentialBoxes();
  }

  // ===========================================================================
  // ADAPTER REGISTRATION
  // ===========================================================================
  static void registerAdapters() {
    // Settings
    Hive.registerAdapter(UserSettingsAdapter());

    // Practice & history
    Hive.registerAdapter(PracticeLogAdapter());
    Hive.registerAdapter(QuestionHistoryAdapter());

    // Scores
    Hive.registerAdapter(DailyScoreAdapter());

    // Streak
    Hive.registerAdapter(StreakDataAdapter());
  }

  // ===========================================================================
  // ESSENTIAL BOXES
  // ===========================================================================
  static Future<void> openEssentialBoxes() async {
    // 🧠 Local user identity
    await Hive.openBox('local_user');

    // ⚙️ App settings
    await Hive.openBox<UserSettings>('user_settings');

    // 🔥 Streak tracking
    await Hive.openBox<StreakData>('streak_data');

    // 📊 Activity heatmap
    await Hive.openBox<Map>('activity_data');

    // 🧾 Practice logs
    await Hive.openBox<PracticeLog>('practice_logs');
    await Hive.openBox<QuestionHistory>('question_history');

    // 📈 Scores
    await Hive.openBox<DailyScore>('daily_scores'); // heatmap & graphs
    await Hive.openBox<DailyScore>('practice_scores');
    await Hive.openBox<DailyScore>('ranked_scores');
    await Hive.openBox<DailyScore>('mixed_scores');

    // 🌍 Leaderboard cache (optional offline view)
    await Hive.openBox('leaderboard_cache');

    // 🔄 Sync queue (for failed leaderboard submits)
    await Hive.openBox<Map>('sync_queue');
  }

  // ===========================================================================
  // ACCESSORS
  // ===========================================================================

  // Local user
  static Box get localUserBox => Hive.box('local_user');

  // Settings
  static Box<UserSettings> get userSettingsBox =>
      Hive.box<UserSettings>('user_settings');

  // Logs
  static Box<PracticeLog> get practiceLogBox =>
      Hive.box<PracticeLog>('practice_logs');

  static Box<QuestionHistory> get questionHistoryBox =>
      Hive.box<QuestionHistory>('question_history');

  // Scores
  static Box<DailyScore> get dailyScoreBox =>
      Hive.box<DailyScore>('daily_scores');

  static Box<DailyScore> get practiceScoreBox =>
      Hive.box<DailyScore>('practice_scores');

  static Box<DailyScore> get rankedScoreBox =>
      Hive.box<DailyScore>('ranked_scores');

  static Box<DailyScore> get mixedScoreBox =>
      Hive.box<DailyScore>('mixed_scores');

  // Streak
  static Box<StreakData> get streakDataBox =>
      Hive.box<StreakData>('streak_data');

  // Misc
  static Box get leaderboardCacheBox => Hive.box('leaderboard_cache');

  static Box<Map> get syncQueueBox => Hive.box<Map>('sync_queue');

  static Box<Map> get activityDataBox => Hive.box<Map>('activity_data');
}
