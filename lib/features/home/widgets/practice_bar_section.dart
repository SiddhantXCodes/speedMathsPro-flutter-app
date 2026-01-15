// lib/features/home/widgets/practice_bar_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../services/hive_service.dart';
import '../../../providers/performance_provider.dart';
import '../../quiz/screens/daily_ranked_quiz_entry.dart';
import '../../quiz/widgets/quiz_entry_popup.dart';
import '../../quiz/screens/practice_quiz_entry.dart';
import '../../quiz/screens/setup/mixed_quiz_setup_screen.dart';

class PracticeBarSection extends StatefulWidget {
  const PracticeBarSection({super.key});

  @override
  State<PracticeBarSection> createState() => _PracticeBarSectionState();
}

class _PracticeBarSectionState extends State<PracticeBarSection> {
  bool attemptedToday = false;

  @override
  void initState() {
    super.initState();

    _loadLocalRankedState();

    // 🔁 Auto-refresh after quiz completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerformanceProvider>().addListener(_loadLocalRankedState);
    });
  }

  @override
  void dispose() {
    context.read<PerformanceProvider>().removeListener(_loadLocalRankedState);
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // LOAD LOCAL RANKED STATUS (OFFLINE)
  // --------------------------------------------------------------------------
  Future<void> _loadLocalRankedState() async {
    attemptedToday = await HiveService.hasRankedAttemptToday();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);

    // ⏳ Cooldown timer
    String? cooldownText;
    if (attemptedToday) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final diff = tomorrow.difference(now);
      cooldownText = "Next quiz in ${diff.inHours}h";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveCard(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ Daily Ranked Quiz
          _PracticeCard(
            title: "Daily Ranked Quiz",
            subtitle: attemptedToday
                ? "You’ve already played today"
                : "1 attempt • 150 seconds timer",
            icon: Icons.flash_on_rounded,
            color: accent,
            badge: cooldownText,
            onTap: () {
              if (attemptedToday) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "You’ve already played today. Come back tomorrow!",
                    ),
                  ),
                );
                return;
              }

              showQuizEntryPopup(
                context: context,
                title: "Daily Ranked Quiz",
                infoLines: const [
                  "150 seconds timer",
                  "Score = total correct answers",
                  "1 attempt per day",
                ],
                onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyRankedQuizEntry(),
                    ),
                  ).then((_) => _loadLocalRankedState());
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // 🧩 Daily Practice Quiz
          _PracticeCard(
            title: "Daily Practice Quiz",
            subtitle: "Train like ranked — no limits.",
            icon: Icons.school_rounded,
            color: accent,
            onTap: () {
              showQuizEntryPopup(
                context: context,
                title: "Daily Practice Quiz",
                infoLines: const [
                  "150 seconds timer",
                  "Unlimited attempts per day",
                ],
                onStart: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeQuizEntry(),
                    ),
                  );
                },
                showPracticeLink: false,
                showHistoryButton: true,
              );
            },
          ),

          const SizedBox(height: 14),

          // 🔀 Mixed Practice
          _PracticeCard(
            title: "Mixed Practice",
            subtitle: "Customize multiple topics.",
            icon: Icons.shuffle_rounded,
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MixedQuizSetupScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRACTICE CARD (PRIVATE)
// ============================================================================
class _PracticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5,
                            color: textColor,
                          ),
                        ),
                      ),

                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
