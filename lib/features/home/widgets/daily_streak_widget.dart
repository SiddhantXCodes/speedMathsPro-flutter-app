import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../services/hive_service.dart';
import '../../quiz/screens/daily_ranked_quiz_entry.dart';

class DailyStreakWidget extends StatefulWidget {
  const DailyStreakWidget({super.key});

  @override
  State<DailyStreakWidget> createState() => _DailyStreakWidgetState();
}

class _DailyStreakWidgetState extends State<DailyStreakWidget>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseController;

  static const streakGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🔥 LOCAL, OFFLINE-SAFE STREAK CALCULATION
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // TAP HANDLER
  // ---------------------------------------------------------------------------
  Future<void> _handleStreakTap() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final hasPlayedToday = await HiveService.hasRankedAttemptToday();

    if (!hasPlayedToday) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const DailyRankedQuizEntry(),
        ),
      );

      if (!mounted) return;
      setState(() {}); // refresh streak
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔥 You’ve already completed today’s ranked quiz!"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final streak = _calculateStreak();
    final textColor = AppTheme.adaptiveText(context);

    return Opacity(
      opacity: _isLoading ? 0.6 : 1,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleStreakTap,
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulseController,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) => streakGradient.createShader(b),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                "$streak",
                key: ValueKey(streak),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: streak > 0
                      ? const Color(0xFFFF5722)
                      : textColor.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
