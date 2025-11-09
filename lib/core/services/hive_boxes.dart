import 'package:hive_flutter/hive_flutter.dart';

// 🧩 Core Models
import '../models/user_profile.dart';
import '../models/user_settings.dart';

// 🧩 Feature Models
import '../../../features/practice/data/models/practice_log.dart';
import '../../../features/practice/data/models/question_history.dart';
import '../../../features/performance/data/models/daily_score.dart';
import '../../../features/quiz/data/models/daily_quiz_meta.dart';
import '../../../features/quiz/data/models/streak_data.dart';

/// 🧠 Centralized Hive Box & Adapter Registration
/// Ensures all models are properly initialized and opened.
class HiveBoxes {
  /// ----------------------------------------------------------
  /// 🚀 Initialize Hive and open essential boxes
  /// ----------------------------------------------------------
  static Future<void> init() async {
    await Hive.initFlutter();

    registerAdapters();

    // ⚡ Open essential boxes synchronously
    await openEssentialBoxes();

    // 🚀 Open heavy boxes lazily (background)
    openBackgroundBoxes();
  }

  /// ----------------------------------------------------------
  /// 🔹 Register all Hive adapters (before opening any box)
  /// ----------------------------------------------------------
  static void registerAdapters() {
    // Core
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Practice Feature
    Hive.registerAdapter(PracticeLogAdapter());
    Hive.registerAdapter(QuestionHistoryAdapter());

    // Performance Feature
    Hive.registerAdapter(DailyScoreAdapter());

    // Quiz Feature
    Hive.registerAdapter(DailyQuizMetaAdapter());
    Hive.registerAdapter(StreakDataAdapter());
  }

  /// ----------------------------------------------------------
  /// 📦 Essential boxes (fast, always needed)
  /// ----------------------------------------------------------
  static Future<void> openEssentialBoxes() async {
    await Hive.openBox<UserProfile>('user_profile');
    await Hive.openBox<UserSettings>('user_settings');
    await Hive.openBox<StreakData>('streak_data');
  }

  /// ----------------------------------------------------------
  /// 🧠 Background or large boxes (can load asynchronously)
  /// ----------------------------------------------------------
  static Future<void> openBackgroundBoxes() async {
    // Use `Future.microtask` to prevent blocking UI thread
    Future.microtask(() async {
      await Hive.openBox<PracticeLog>('practice_logs');
      await Hive.openBox<QuestionHistory>('question_history');
      await Hive.openBox<DailyScore>('daily_scores');
      await Hive.openBox<DailyQuizMeta>('daily_quiz_meta');
      await Hive.openBox('leaderboard_cache');
      await Hive.openBox<Map>('sync_queue');
      await Hive.openBox<Map>('activity_data');
    });
  }

  /// ----------------------------------------------------------
  /// 🧩 Easy accessors for frequently used boxes
  /// ----------------------------------------------------------
  static Box<UserProfile> get userProfileBox =>
      Hive.box<UserProfile>('user_profile');
  static Box<UserSettings> get userSettingsBox =>
      Hive.box<UserSettings>('user_settings');
  static Box<PracticeLog> get practiceLogBox =>
      Hive.box<PracticeLog>('practice_logs');
  static Box<QuestionHistory> get questionHistoryBox =>
      Hive.box<QuestionHistory>('question_history');
  static Box<DailyScore> get dailyScoreBox =>
      Hive.box<DailyScore>('daily_scores');
}
