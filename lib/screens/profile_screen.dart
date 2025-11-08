import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,

      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = FirebaseAuth.instance.currentUser;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: theme.colorScheme.surfaceVariant
                          .withOpacity(0.4),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user == null
                          ? Icon(Icons.person, size: 42)
                          : user.photoURL == null
                          ? Text(
                              _getUserInitial(user),
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),

                    // Name / Email
                    Text(
                      _capitalizeName(user?.displayName ?? "Guest User"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      user?.email ?? "Not signed in",
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔐 Login Button (if not logged in)
                    if (user == null)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Login or Register",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Settings Section
              _sectionTitle("Settings", textColor),
              _tile(
                icon: themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: "Dark Mode",
                subtitle: themeProvider.isDark ? "Enabled" : "Disabled",
                onTap: () => themeProvider.toggleTheme(),
              ),
              _tile(
                icon: Icons.notifications_active_rounded,
                title: "Notifications",
                subtitle: "Coming soon",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              _sectionTitle("Feedback & Support", textColor),
              _tile(
                icon: Icons.star_rate_rounded,
                title: "Rate the App",
                subtitle: "Share your experience",
                onTap: () {},
              ),
              _tile(
                icon: Icons.feedback_rounded,
                title: "Send Feedback",
                subtitle: "Help us improve SpeedMath",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              if (user != null)
                ElevatedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Signed out successfully.")),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getUserInitial(User user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    } else if (user.email != null && user.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return "?";
  }

  String _capitalizeName(String name) {
    return name
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
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
