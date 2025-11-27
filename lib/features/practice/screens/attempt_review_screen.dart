// lib/features/practice/screens/attempt_review_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

class AttemptReviewScreen extends StatelessWidget {
  final Map<String, dynamic> attempt;

  const AttemptReviewScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final cardColor = AppTheme.adaptiveCard(context);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final accent = AppTheme.adaptiveAccent(context);

    final List questions = attempt['questions'] ?? [];
    final Map userAnswers = attempt['userAnswers'] ?? {};

    final date = attempt['date'] ?? attempt['timestamp'];
    final formattedDate = date != null
        ? DateFormat.yMMMd().add_jm().format(date)
        : "Unknown";

    final topic = attempt['topic'] ?? "Practice Session";
    final type = attempt['category'] ?? "Practice";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: accent,
        title: const Text("Review Attempt"),
        centerTitle: true,
      ),

      body: questions.isEmpty
          ? Center(
              child: Text(
                "No detailed data available for this attempt",
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                // -------------------- SUMMARY CARD ---------------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$type • $formattedDate",
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --------------------- QUESTION LIST ---------------------
                ListView.builder(
                  itemCount: questions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final q = questions[index];

                    final expression = q is Map
                        ? (q['expression']?.toString() ?? "")
                        : q.toString();

                    final correct = q is Map
                        ? (q['correctAnswer']?.toString() ?? "")
                        : "";

                    final given = userAnswers[index]?.toString() ?? "";

                    final bool isCorrect =
                        correct.isNotEmpty && correct.trim() == given.trim();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect
                                ? AppTheme.successColor
                                : AppTheme.dangerColor,
                            size: 26,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expression,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  "Your Answer: $given",
                                  style: TextStyle(
                                    color: isCorrect
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                Text(
                                  "Correct Answer: $correct",
                                  style: TextStyle(
                                    color: AppTheme.successColor.withOpacity(
                                      0.85,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
