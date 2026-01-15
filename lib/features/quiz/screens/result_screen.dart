import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../home/screens/home_screen.dart';
import '../../performance/screens/performance_screen.dart';
import 'leaderboard_screen.dart';
import '../../../services/hive_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int timeTakenSeconds;
  final String title; // Ranked Result / Practice Result / Mixed Result

  const ResultScreen({
    super.key,
    required this.score,
    required this.timeTakenSeconds,
    this.title = "Quiz Result",
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  /// Ranked or not (based on title)
  bool get isRanked =>
      widget.title.toLowerCase().contains("ranked");

  /// ✅ LOCAL, OFFLINE-SAFE STREAK CALCULATION
  int _calculateStreak() {
    final ranked = HiveService.getRankedScores();
    if (ranked.isEmpty) return 0;

    final dates = ranked
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    int streak = 0;
    DateTime day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);

    while (dates.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    final mins = (widget.timeTakenSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (widget.timeTakenSeconds % 60).toString().padLeft(2, '0');

    final streak = isRanked ? _calculateStreak() : 0;

    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: accent,
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _goHome(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🏆 SCORE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber,
                      size: 42,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Your Score",
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "${widget.score}",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time: ${mins}m ${secs}s",
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 Ranked Badge
              if (isRanked) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_fire_department,
                          color: Colors.orange),
                      SizedBox(width: 6),
                      Text(
                        "Ranked Attempt Recorded",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],

              // 🔁 Streak feedback (derived, not stored)
              if (isRanked) ...[
                const SizedBox(height: 8),
                Text(
                  streak > 0
                      ? "🔥 Streak: $streak days"
                      : "Start your daily streak!",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: streak > 0
                        ? Colors.deepOrange
                        : textColor.withOpacity(0.7),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 🔘 ACTIONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.home),
                      label: const Text("Home"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _goHome(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.leaderboard),
                      label: const Text("Leaderboard"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.insights),
                  label: const Text("Performance"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PerformanceScreen(),
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

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }
}
