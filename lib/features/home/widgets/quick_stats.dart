// lib/features/home/widgets/quick_stats.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../services/hive_service.dart';
import '../../../providers/performance_provider.dart';
import '../../performance/screens/performance_screen.dart';

class QuickStatsSection extends StatefulWidget {
  final bool isDarkMode;
  const QuickStatsSection({super.key, required this.isDarkMode});

  @override
  State<QuickStatsSection> createState() => _QuickStatsSectionState();
}

class _QuickStatsSectionState extends State<QuickStatsSection> {
  int sessions = 0;
  int bestScore = 0;
  int weeklyAvg = 0;
  bool attemptedToday = false;

  @override
  void initState() {
    super.initState();

    _loadStats();

    // 🔁 Auto-refresh when performance updates (after quiz)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerformanceProvider>().addListener(_loadStats);
    });
  }

  @override
  void dispose() {
    context.read<PerformanceProvider>().removeListener(_loadStats);
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // LOAD STATS (OFFLINE ONLY)
  // --------------------------------------------------------------------------
  Future<void> _loadStats() async {
    final all = [
      ...HiveService.getPracticeScores(),
      ...HiveService.getMixedScores(),
    ];

    sessions = all.length;

    int best = 0;
    int sum = 0;
    int count = 0;
    final now = DateTime.now();

    for (final s in all) {
      if (s.score > best) best = s.score;

      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (now.difference(d).inDays <= 6) {
        sum += s.score;
        count++;
      }
    }

    bestScore = best;
    weeklyAvg = count > 0 ? (sum ~/ count) : 0;

    // 🔒 Offline ranked check
    attemptedToday = await HiveService.hasRankedAttemptToday();

    if (mounted) setState(() {});
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final cardColor = AppTheme.adaptiveCard(context);
    final textColor = AppTheme.adaptiveText(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quick Stats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformanceScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.insights, color: accent),
                label: Text(
                  "Performance",
                  style: TextStyle(color: accent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _valueBox(Icons.school, "Sessions", sessions, accent),
              _valueBox(Icons.stars, "Best", bestScore, accent),
              _valueBox(Icons.show_chart, "Weekly Avg", weeklyAvg, accent),
            ],
          ),

          const SizedBox(height: 16),

          // Ranked status (offline)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              attemptedToday
                  ? "🎯 You’ve completed today’s Ranked Quiz"
                  : "⚡ Today’s Ranked Quiz is available",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // VALUE BOX
  // --------------------------------------------------------------------------
  Widget _valueBox(
    IconData icon,
    String title,
    int value,
    Color accent,
  ) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(height: 4),
        Text(
          "$value",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: accent,
            fontSize: 15,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: accent.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
