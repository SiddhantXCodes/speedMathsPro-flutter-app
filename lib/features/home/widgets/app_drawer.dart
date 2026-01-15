// lib/features/home/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/local_user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LocalUserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: accent.withOpacity(0.25),
                    child: Text(
                      user.hasUsername
                          ? user.username![0].toUpperCase()
                          : "?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.username ?? "Guest",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================= MENU ITEMS =================
            _item(
              icon: Icons.person_rounded,
              title: "Profile & Settings",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),

            _item(
              icon: themeProvider.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              title: themeProvider.isDark ? "Light Mode" : "Dark Mode",
              onTap: () {
                themeProvider.toggleTheme();
                Navigator.pop(context);
              },
            ),

            _item(
              icon: Icons.info_outline_rounded,
              title: "About",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // ================= FOOTER =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "SpeedMath Pro v1.0",
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
