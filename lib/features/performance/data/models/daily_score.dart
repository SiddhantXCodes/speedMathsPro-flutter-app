import 'package:hive/hive.dart';

part 'daily_score.g.dart';

/// 📊 DailyScore — stores a user's daily quiz performance (offline + online)
/// Used for both Hive (offline caching) and Firebase sync.
@HiveType(typeId: 6)
class DailyScore extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final int totalQuestions;

  @HiveField(3)
  final int timeTakenSeconds;

  @HiveField(4)
  final bool isRanked; // true = daily ranked quiz, false = practice quiz

  DailyScore({
    required this.date,
    required this.score,
    this.totalQuestions = 0,
    this.timeTakenSeconds = 0,
    this.isRanked = true,
  });

  /// ----------------------------------------------------------
  /// 🔁 Convert model → Map (for Firebase/Hive storage)
  /// ----------------------------------------------------------
  Map<String, dynamic> toMap() => {
    'date': date.toIso8601String(),
    'score': score,
    'totalQuestions': totalQuestions,
    'timeTakenSeconds': timeTakenSeconds,
    'isRanked': isRanked,
  };

  /// ----------------------------------------------------------
  /// 🧩 Convert Map → model (for rebuilding from cache or Firebase)
  /// ----------------------------------------------------------
  factory DailyScore.fromMap(Map<String, dynamic> map) {
    return DailyScore(
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      isRanked: map['isRanked'] ?? true,
    );
  }

  /// ----------------------------------------------------------
  /// 🧾 For quick debug prints
  /// ----------------------------------------------------------
  @override
  String toString() {
    return 'DailyScore(date: $date, score: $score, total: $totalQuestions, '
        'time: $timeTakenSeconds, ranked: $isRanked)';
  }
}
