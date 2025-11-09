import 'package:flutter/material.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../../performance/presentation/providers/performance_provider.dart';

import '../../../practice/presentation/providers/practice_log_provider.dart';

class WeeklySummaryCard extends StatelessWidget {
  final PerformanceProvider perf;
  final PracticeLogProvider log;

  const WeeklySummaryCard({super.key, required this.perf, required this.log});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    final avgSpeed = log.logs.isNotEmpty
        ? log.logs.map((e) => e.avgTime).reduce((a, b) => a + b) /
              log.logs.length
        : 0.0;

    final currentWeekScore = perf.weeklyAverage ?? 0;
    final previousWeekScore = (currentWeekScore * 0.75).round();
    final currentAccuracy = _calculateAccuracy(log);
    final previousAccuracy = (currentAccuracy * 0.8).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Comparison",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _progressRow(
            "Average Score",
            previousWeekScore,
            currentWeekScore,
            accent,
          ),
          const SizedBox(height: 10),
          _progressRow("Accuracy", previousAccuracy, currentAccuracy, accent),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryStat(
                Icons.timer_rounded,
                "Avg Speed",
                "${avgSpeed.toStringAsFixed(1)}s",
                accent,
              ),
              const SizedBox(width: 10),
              _summaryStat(
                Icons.trending_up_rounded,
                "7-Day Avg",
                "$currentWeekScore",
                accent,
              ),
              const SizedBox(width: 10),
              _summaryStat(
                Icons.check_circle_rounded,
                "Accuracy",
                "$currentAccuracy%",
                accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, int oldVal, int newVal, Color accent) {
    final increase = newVal >= oldVal;
    final fillPercent = (newVal.clamp(0, 100)) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              "$newVal",
              style: TextStyle(
                color: increase ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fillPercent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryStat(IconData icon, String title, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateAccuracy(PracticeLogProvider log) {
    int correct = 0, wrong = 0;
    for (final l in log.logs) {
      correct += l.correct;
      wrong += l.incorrect;
    }
    final total = correct + wrong;
    if (total == 0) return 0;
    return ((correct / total) * 100).round();
  }
}
