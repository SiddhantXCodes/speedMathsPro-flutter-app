// lib/features/quiz/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'quiz_screen.dart';
import '../../../theme/app_theme.dart';
import '../usecase/generate_questions.dart';
import '../../performance/screens/performance_screen.dart';
import '../../home/screens/home_screen.dart';
import 'leaderboard_screen.dart';
import '../../../providers/performance_provider.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final int total;
  final int score;
  final int correct;
  final int incorrect;
  final int timeTakenSeconds;
  final Map<int, String> userAnswers;
  final List<Question> questions;
  final QuizMode mode;

  const ResultScreen({
    super.key,
    required this.title,
    required this.total,
    required this.score,
    required this.correct,
    required this.incorrect,
    required this.timeTakenSeconds,
    required this.userAnswers,
    required this.questions,
    this.mode = QuizMode.practice,
  });

  bool get isRanked => mode == QuizMode.dailyRanked;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    // Ranked → refresh Firebase streak only
    if (isRanked) {
      Future.microtask(() {
        final perf = Provider.of<PerformanceProvider>(context, listen: false);
        perf.reloadAll();
      });
    }

    final mins = (timeTakenSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (timeTakenSeconds % 60).toString().padLeft(2, '0');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          backgroundColor: accent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.adaptiveText(context),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          title: Text(
            isRanked ? "Ranked Result" : "Quiz Result",
            style: TextStyle(
              color: AppTheme.adaptiveText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ⭐ Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: isRanked ? Colors.amber : accent,
                      size: 40,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your Score",
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "$score",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Correct: $correct | Incorrect: $incorrect",
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Time Taken: $mins:$secs",
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔘 Buttons Row
              Row(
                children: [
                  // HOME BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded, color: Colors.white),
                      label: const Text(
                        "Home",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  if (isRanked) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.leaderboard_rounded),
                        label: const Text(
                          "Leaderboard",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: accent, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // 📊 Performance Page Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerformanceScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text(
                    "Performance Page",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent, width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Question Review",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 📄 Review List
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final userAns = userAnswers[index];
                    final correctAns = q.correctAnswer.trim();
                    final isCorrect =
                        userAns != null && userAns.trim() == correctAns;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.08)
                            : Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.4)
                              : Colors.red.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${index + 1}. ${q.expression}",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Your answer: ${userAns ?? '-'}",
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Correct answer: $correctAns",
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
