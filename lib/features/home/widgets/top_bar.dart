// lib/features/home/widgets/top_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/local_user_provider.dart';
import '../../profile/profile_screen.dart';
/// 🔝 App-wide TopBar shown on HomeScreen.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<LocalUserProvider>();
    final theme = Theme.of(context);

    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final isDarkMode = themeProvider.isDark;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,

      // ☰ Drawer button (FIXED)
      leading: Builder(
        builder: (scaffoldContext) => IconButton(
          icon: Icon(Icons.menu_rounded, color: textColor),
          onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
        ),
      ),

      title: Text(
        'SpeedMath Pro',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 20,
        ),
      ),

      actions: [
        // 🌗 Theme toggle
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDarkMode),
              color: accent,
            ),
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),

        const SizedBox(width: 8),

        // 👤 User avatar (opens drawer)
        Builder(
          builder: (scaffoldContext) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const ProfileScreen(),
    ),
  );
},
              child: CircleAvatar(
                radius: 18,
                backgroundColor: accent.withOpacity(0.15),
                child: Text(
                  user.hasUsername
                      ? user.username![0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
