import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../../performance/performance_provider.dart';
import '../../practice/practice_log_provider.dart';
import '../../../theme/app_theme.dart';
import '../widgets/practice_bar_section.dart';
import '../widgets/top_bar.dart';
import '../widgets/quick_stats.dart';
import '../widgets/heatmap_section.dart';

// 📊 Feature Screens
import '../../performance/screens/performance_screen.dart';
import '../../practice/screens/attempts_history_screen.dart';
import '../../learn_daily/learn_daily_screen.dart';
import '../../tips/screens/tips_home_screen.dart';
import 'package:speedmaths_pro/debug/hive_debug_screen.dart';

/// 🏠 Home Screen — Pull-Down Refresh Only
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  /// 🔄 Manual pull-down refresh
  Future<void> _refreshActivityData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final performance = Provider.of<PerformanceProvider>(
        context,
        listen: false,
      );
      final practice = Provider.of<PracticeLogProvider>(context, listen: false);

      await Future.wait([performance.reloadAll(), practice.loadLogs()]);

      debugPrint("✅ Manual home refresh completed");
    } catch (e) {
      debugPrint("⚠️ Manual refresh failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("⚠️ Refresh failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Color _colorForValue(int v) {
    switch (v.clamp(0, 4)) {
      case 0:
        return const Color(0xFFEBEDF0);
      case 1:
        return const Color(0xFF9BE9A8);
      case 2:
        return const Color(0xFF40C463);
      case 3:
        return const Color(0xFF30A14E);
      default:
        return const Color(0xFF216E39);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final practice = Provider.of<PracticeLogProvider>(context);
    final performance = Provider.of<PerformanceProvider>(context);

    final activity = _mergeActivityMaps(
      practice.getActivityMap(),
      performance.dailyScores.keys.toList(),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: TopBar(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshActivityData,
          color: theme.colorScheme.primary,
          backgroundColor: theme.cardColor,
          displacement: 70,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _buildWelcomeSection(context),
                const SizedBox(height: 16),

                QuickStatsSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                ),

                const SizedBox(height: 20),
                const PracticeBarSection(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HiveDebugScreen(),
                      ),
                    );
                  },
                  child: const Text("Open Hive Debug Viewer"),
                ),
                _buildFeatureCard(
                  context,
                  title: "Learn Daily",
                  subtitle: "A new math concept to explore every day 🔥",
                  icon: Icons.menu_book_rounded,
                  gradientColors: [
                    theme.colorScheme.primary.withOpacity(0.15),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                  iconColor: Colors.blueAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LearnDailyScreen()),
                  ),
                ),

                const SizedBox(height: 20),

                _buildFeatureCard(
                  context,
                  title: "Tips & Tricks",
                  subtitle: "Quick math hacks to improve efficiency ⚡",
                  icon: Icons.lightbulb_rounded,
                  gradientColors: [
                    Colors.orangeAccent.withOpacity(0.15),
                    Colors.orangeAccent.withOpacity(0.05),
                  ],
                  iconColor: Colors.orangeAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TipsHomeScreen()),
                  ),
                ),

                const SizedBox(height: 20),

                _buildWideInfoCard(
                  context,
                  title: "Practice History",
                  subtitle: "Review your past quizzes & progress",
                  icon: Icons.history_rounded,
                  accentColor: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttemptsHistoryScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _buildWideInfoCard(
                  context,
                  title: "Performance Insights",
                  subtitle: "Track your accuracy & speed trends over time",
                  icon: Icons.trending_up_rounded,
                  accentColor: Colors.purpleAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformanceScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                _buildSectionHeader("Your Activity"),
                const SizedBox(height: 8),
                HeatmapSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                  activity: activity,
                  colorForValue: _colorForValue,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 👋 Welcome Header
  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back 👋",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let’s boost your math speed today!",
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  /// 🌈 Reusable Feature Card
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: gradientColors.first.withOpacity(0.2),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  /// 📈 Reusable Wide Info Card
  Widget _buildWideInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withOpacity(0.15), width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 26, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  /// 🧭 Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    );
  }

  /// 🔄 Merge Offline + Online Activity
  Map<DateTime, int> _mergeActivityMaps(
    Map<DateTime, int> offline,
    List<DateTime> ranked,
  ) {
    final merged = Map<DateTime, int>.from(offline);
    for (final d in ranked) {
      final k = DateTime(d.year, d.month, d.day);
      merged[k] = (merged[k] ?? 0) + 1;
    }
    return merged.map((k, v) => MapEntry(k, v.clamp(0, 5)));
  }
}
