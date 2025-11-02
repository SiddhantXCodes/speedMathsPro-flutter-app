// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'level_select_screen.dart';
import '../models/level_model.dart';
import '../providers/quiz_provider.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
  final Level level;
  final int score; // points (e.g. 70)
  final int totalQuestions; // number of questions (e.g. 10)
  final int coinsEarned;

  const ResultScreen({
    Key? key,
    required this.level,
    required this.score,
    required this.totalQuestions,
    required this.coinsEarned,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // compute display values locally (no Provider dependency required)
    final int totalPossible = totalQuestions * 10; // 10 points per question
    final double pct = totalPossible > 0 ? (score / totalPossible) * 100 : 0.0;
    final bool isPassed = pct >= 70.0;

    // For debug (temporary) — remove for production
    // print('RESULT DEBUG -> score:$score totalPossible:$totalPossible pct:$pct');

    return Scaffold(
      backgroundColor: isPassed ? Colors.green.shade50 : Colors.red.shade50,
      appBar: AppBar(
        title: Text('Level ${level.levelNumber} Result'),
        backgroundColor: isPassed ? Colors.green : Colors.red,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPassed
                    ? Icons.emoji_events_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: isPassed ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                isPassed ? '🎉 Congratulations!' : '😔 Try Again!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPassed
                    ? 'You cleared Level ${level.levelNumber}.\nNice work — move to the next level!'
                    : 'You scored below the passing mark.\nPractice and try again!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 28,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Score: $score / $totalPossible',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isPassed
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coins earned: $coinsEarned',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Levels'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Reset live quiz state if you want
                      final quizProv = Provider.of<QuizProvider>(
                        context,
                        listen: false,
                      );
                      quizProv.reset();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(
                      isPassed
                          ? Icons.arrow_forward_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(isPassed ? 'Next Level' : 'Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPassed ? Colors.green : Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Reset live quiz state when leaving results; then go back to level screen
                      final quizProv = Provider.of<QuizProvider>(
                        context,
                        listen: false,
                      );
                      if (isPassed) {
                        quizProv.unlockNextLevel();
                      }
                      quizProv.reset();

                      // 🏠 Navigate back to Level Selection Screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectionScreen(),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
