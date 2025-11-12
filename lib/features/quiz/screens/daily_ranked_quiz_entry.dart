// lib/features/ranked/presentation/screens/daily_ranked_quiz_entry.dart
import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import '../../home/screens/home_screen.dart';

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
      onFinish: (result) async {
        // wait a bit to ensure Firestore write completes
        await Future.delayed(const Duration(milliseconds: 600));

        if (context.mounted) {
          // Replace current screen with refreshed HomeScreen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false, // remove old screens from stack
          );
        }
      },
    );
  }
}
