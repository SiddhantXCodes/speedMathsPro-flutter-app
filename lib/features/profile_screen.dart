// lib/features/settings/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/local_user_provider.dart';
import '../../services/hive_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<LocalUserProvider>();

    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    final name = user.username?.trim() ?? "Player";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: accent,
        title: const Text("Profile & Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 PROFILE
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _editName(context, user),
                  style: ElevatedButton.styleFrom(backgroundColor: accent),
                  child: const Text("Edit Name"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          _sectionTitle("Settings", textColor),

          _tile(
            icon: themeProvider.isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: "Dark Mode",
            subtitle: themeProvider.isDark ? "Enabled" : "Disabled",
            onTap: themeProvider.toggleTheme,
          ),

          _tile(
            icon: Icons.delete_outline_rounded,
            title: "Reset All Data",
            subtitle: "Clear all local progress",
            onTap: () async {
              await HiveService.clearAllOfflineData();
              await user.clearUsername();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All local data cleared")),
              );
            },
          ),

          const SizedBox(height: 20),

          _sectionTitle("About", textColor),

          _tile(
            icon: Icons.info_outline_rounded,
            title: "App Version",
            subtitle: "SpeedMath Pro v1.0.0",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context, LocalUserProvider user) {
    final ctrl = TextEditingController(text: user.username ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.length >= 3) {
                user.setUsername(name);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color.withOpacity(0.8),
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 26),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
