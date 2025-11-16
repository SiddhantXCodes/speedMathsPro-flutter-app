// lib/features/quiz/screens/daily_ranked_quiz_entry.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/quiz_entry_popup.dart';
import 'quiz_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../providers/performance_provider.dart';

class DailyRankedQuizEntry extends StatelessWidget {
  const DailyRankedQuizEntry({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      showQuizEntryPopup(
        context: context,
        title: "Daily Ranked Quiz",
        infoLines: [
          "10 questions fixed for all users.",
          "Total time: 60 seconds.",
          "Only one attempt allowed per day.",
          "Leaderboard ranking is based on score & time.",
          "If unsure, try Practice first.",
        ],
        showPracticeLink: true,
        questionCount: 10,
        timeSeconds: 60,

        onStart: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                title: "Daily Ranked Quiz",
                min: 1,
                max: 50,
                count: 10,
                mode: QuizMode.dailyRanked,
                timeLimitSeconds: 180,

                onFinish: (result) async {
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (context.mounted) {
                    await context.read<PerformanceProvider>().reloadAll();
                  }

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          );
        },
      )
      // 👇 auto-return to home when popup closed via back
      .whenComplete(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      });
    });

    return const SizedBox.shrink();
  }
}
