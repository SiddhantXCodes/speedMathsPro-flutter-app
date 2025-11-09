// lib/features/ranked/presentation/screens/daily_ranked_quiz_entry.dart
import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class DailyRankedQuizEntry extends StatelessWidget {
  const DailyRankedQuizEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return QuizScreen(
      title: "Daily Ranked Quiz",
      min: 1,
      max: 50,
      count: 10,
      mode: QuizMode.dailyRanked,
      timeLimitSeconds: 180,
    );
  }
}
