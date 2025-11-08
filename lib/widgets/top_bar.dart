import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app.dart';
import '../theme/app_theme.dart';
import '../screens/profile_screen.dart';

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
    final themeProvider = ThemeProvider();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = themeProvider.isDark;

    final accent = AppTheme.adaptiveAccent(context);
    final onSurface = colorScheme.onSurface;
    final mutedOnSurface = onSurface.withOpacity(0.68);
    final streakActive = AppTheme.warningColor;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.transparent,
      elevation: theme.appBarTheme.elevation ?? 0,
      title: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: onSurface,
          fontSize: 20,
        ),
        child: const Text('SpeedMath'),
      ),
      actions: [
        // 🌓 Theme Toggle (still available on top)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.7, end: 2).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: IconButton(
            key: ValueKey<bool>(isDarkMode),
            icon: Icon(
              isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              color: isDarkMode ? streakActive : accent,
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
                color: userStreak > 0 ? streakActive : mutedOnSurface,
              ),
              const SizedBox(width: 4),
              Text(
                '$userStreak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: userStreak > 0 ? streakActive : mutedOnSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 👤 Profile Icon (changes automatically after login)
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            color: accent,
                            size: 22,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
