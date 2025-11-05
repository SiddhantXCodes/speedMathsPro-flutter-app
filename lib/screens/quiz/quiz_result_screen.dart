// lib/screens/quiz/quiz_result_screen.dart
import 'package:flutter/material.dart';
import '../../utils/question_generator.dart';

class QuizResultScreen extends StatelessWidget {
  final String title;
  final int correct;
  final int incorrect;
  final int total;
  final String time;
  final List<Question> questions;
  final Map<int, String> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.incorrect,
    required this.total,
    required this.time,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final score = ((correct / total) * 100).round();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Score: $score%", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text("Time: $time", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    "Correct: $correct  |  Incorrect: $incorrect",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            ...List.generate(questions.length, (i) {
              final q = questions[i];
              final user = userAnswers[i];
              final isRight =
                  user != null && _compareAnswers(user, q.correctAnswer);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRight ? Colors.green : Colors.red,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  q.expression.replaceAll('= ?', '= ${q.correctAnswer}'),
                ),
                subtitle: Text(
                  'Your answer: ${user ?? "-"}',
                  style: TextStyle(
                    color: isRight ? Colors.green : Colors.redAccent,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static bool _compareAnswers(String given, String expected) {
    if (given.trim() == expected.trim()) return true;
    final gi = int.tryParse(given.trim()), ei = int.tryParse(expected.trim());
    if (gi != null && ei != null) return gi == ei;
    final gd = double.tryParse(given.trim()),
        ed = double.tryParse(expected.trim());
    return gd != null && ed != null && (gd - ed).abs() < 1e-6;
  }
}
