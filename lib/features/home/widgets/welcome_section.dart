// lib/features/home/widgets/welcome_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/local_user_provider.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localUser = context.watch<LocalUserProvider>();

    final name = localUser.username;
    final firstName =
        (name != null && name.trim().isNotEmpty) ? name.split(' ').first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstName != null ? "Hi $firstName 👋" : "Hi there 👋",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "Ready to sharpen your math reflexes today?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () {
            // You already handle this logic in PracticeBarSection
            // So this button can simply scroll or navigate
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text("Start Daily Ranked Quiz"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
