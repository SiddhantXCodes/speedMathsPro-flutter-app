import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../../../theme/app_theme.dart';
import '../../auth/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../performance/performance_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../quiz/screens/daily_ranked_quiz_entry.dart';

/// 🔝 App-wide TopBar shown on HomeScreen.
/// Displays title, theme toggle, streak count, and profile avatar.
class TopBar extends StatefulWidget {
  final VoidCallback? onToggleToday;

  const TopBar({super.key, this.onToggleToday});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  int _userStreak = 0;
  bool _isLoading = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    // ✅ Delay streak fetch until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStreak();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    try {
      final performance = Provider.of<PerformanceProvider>(
        context,
        listen: false,
      );
      final streak = await performance.fetchCurrentStreak();
      if (mounted) setState(() => _userStreak = streak);
    } catch (e) {
      debugPrint("⚠️ Failed to load streak: $e");
    }
  }

  /// 🔥 Handle streak tap → check quiz completion
  Future<void> _handleStreakTap() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final performance = Provider.of<PerformanceProvider>(
      context,
      listen: false,
    );

    final hasPlayedToday = performance.hasPlayedToday();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!hasPlayedToday && mounted) {
      final shouldStart = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Update Your Streak 🔥"),
          content: const Text(
            "You haven’t completed today’s Daily Ranked Quiz.\n\nWould you like to attempt it now to continue your streak?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Start Quiz"),
            ),
          ],
        ),
      );

      if (shouldStart == true && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyRankedQuizEntry()),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ You’ve already completed today’s ranked quiz!"),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() => _isLoading = false);
    await _loadStreak(); // refresh streak after dialog
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final isDarkMode = themeProvider.isDark;

    const streakGradient = LinearGradient(
      colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final user = auth.user;

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leadingWidth: 0,
      titleSpacing: 16,
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
        SizedBox(
          width: 40,
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween(begin: 0.7, end: 1.0).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                isDarkMode ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDarkMode),
                color: accent,
                size: 24,
              ),
            ),
            tooltip: isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ),

        const SizedBox(width: 8),

        // 🔥 Daily Streak Indicator
        GestureDetector(
          onTap: _handleStreakTap,
          child: Row(
            children: [
              ScaleTransition(
                scale: _pulseController,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      streakGradient.createShader(bounds),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  '$_userStreak',
                  key: ValueKey<int>(_userStreak),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: _userStreak > 0
                        ? const Color(0xFFFF5722)
                        : textColor.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // 👤 User Avatar
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.3), width: 1.3),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                  0.4,
                ),
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user == null
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: accent,
                      )
                    : user.photoURL == null
                    ? Text(
                        _getUserInitial(user.displayName, user.email),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getUserInitial(String? name, String? email) {
    if (name != null && name.isNotEmpty) return name[0].toUpperCase();
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }
}
