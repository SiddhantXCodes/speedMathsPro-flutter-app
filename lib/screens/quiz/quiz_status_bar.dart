import 'package:flutter/material.dart';

class QuizStatusBar extends StatelessWidget {
  final int correct;
  final int incorrect;
  final String timerText;
  final int current;
  final int total;
  final Color textColor;
  final Color cardColor;
  final bool isDark;

  const QuizStatusBar({
    super.key,
    required this.correct,
    required this.incorrect,
    required this.timerText,
    required this.current,
    required this.total,
    required this.textColor,
    required this.cardColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconStatus(Icons.check_circle, correct, Colors.green),
              _iconStatus(Icons.cancel, incorrect, Colors.red),
              _iconStatus(Icons.timer, null, Colors.orange, time: timerText),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: current / total,
                color: Colors.grey[800],
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                minHeight: 6,
                borderRadius: BorderRadius.circular(12),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$current/$total',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconStatus(IconData icon, int? val, Color color, {String? time}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          time ?? '${val ?? 0}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
