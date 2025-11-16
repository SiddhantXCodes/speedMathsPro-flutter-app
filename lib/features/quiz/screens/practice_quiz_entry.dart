// lib/features/quiz/screens/practice_quiz_entry.dart

import 'package:flutter/material.dart';
import '../widgets/quiz_entry_popup.dart';
import 'quiz_screen.dart';
import '../../home/screens/home_screen.dart';

class PracticeQuizEntry extends StatelessWidget {
  const PracticeQuizEntry({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      showQuizEntryPopup(
        context: context,
        title: "Practice Quiz",
        infoLines: [
          "10 random questions.",
          "No attempt limit — practice as much as you want.",
          "Perfect for improving speed & accuracy.",
          "Your results stay offline (no leaderboard).",
        ],
        questionCount: 10,
        timeSeconds: 0,
        showPracticeLink: false,

        onStart: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                title: "Practice Quiz",
                min: 1,
                max: 50,
                count: 10,
                mode: QuizMode.practice,
                timeLimitSeconds: 0,
              ),
            ),
          );
        },
      )
      // 👇 This is the important part
      .whenComplete(() {
        // If popup closed WITHOUT starting quiz → go to home
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      });
    });

    return const SizedBox.shrink();
  }
}
