import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../app.dart'; // ✅ For ThemeProvider

class TopBar extends StatelessWidget {
  final int userStreak;
  final VoidCallback onToggleToday;

  const TopBar({
    super.key,
    required this.userStreak,
    required this.onToggleToday,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDark;
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'SpeedMath',
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      actions: [
        // 🌗 Animated Theme Toggle
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: IconButton(
            key: ValueKey<bool>(isDarkMode),
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: isDarkMode ? Colors.amber : accent,
              size: 26,
            ),
            tooltip: isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ),

        const SizedBox(width: 8),

        // 🔥 Streak counter
        GestureDetector(
          onTap: onToggleToday,
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 26,
                color: userStreak > 0 ? Colors.orangeAccent : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '$userStreak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: userStreak > 0
                      ? Colors.orangeAccent
                      : textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 🧑‍💻 Avatar
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Colors.transparent,
            backgroundImage: const AssetImage('assets/images/elf_icon.png'),
          ),
        ),
      ],
    );
  }
}
