import 'package:flutter/material.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../../performance/presentation/providers/performance_provider.dart';

class LeaderboardHeader extends StatelessWidget {
  final PerformanceProvider provider;
  const LeaderboardHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final user = provider.allTimeRank;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.95), accent.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: provider.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leaderboard Summary",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _pill("Today", provider.todayRank?.toString() ?? "--"),
                    const SizedBox(width: 8),
                    _pill("All-time", provider.allTimeRank?.toString() ?? "--"),
                    const SizedBox(width: 8),
                    _pill("Best", "${provider.bestScore ?? 0} pts"),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
