import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app.dart';
import '../../../performance/presentation/providers/performance_provider.dart';
import '../../../practice/presentation/providers/practice_log_provider.dart';
import '../../../../presentation/theme/app_theme.dart';

// 🧩 Widgets
import '../widgets/top_bar.dart';
import '../widgets/quick_stats.dart';
import '../widgets/heatmap_section.dart';
import '../widgets/home_card.dart';
import '../widgets/smart_practice_section.dart';
import '../widgets/master_basics_section.dart';
import '../widgets/quick_stats.dart';
import '../widgets/heatmap_section.dart';
// 📊 Feature Screens
import '../../../performance/presentation/screens/performance_screen.dart';
import '../../../quiz/presentation/screens/setup/mixed_quiz_setup_screen.dart';
import '../../../practice/presentation/screens/attempts_history_screen.dart';
import '../../../quiz/presentation/screens/leaderboard_screen.dart'; // optional if not created yet

/// 🏠 Home Screen — Enhanced UX Dashboard for SpeedMath Pro
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final double cellSize = 12;
  final double cellSpacing = 4;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _refreshActivityData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => _refreshActivityData();

  Future<void> _refreshActivityData() async {
    try {
      final performance = Provider.of<PerformanceProvider>(
        context,
        listen: false,
      );
      await performance.loadFromLocal(forceReload: true);
    } catch (e) {
      debugPrint("⚠️ Failed to refresh data: $e");
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 👋 Welcome Section
                _buildWelcomeSection(context),

                const SizedBox(height: 16),

                // ⚡ Quick Stats
                QuickStatsSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                ),

                const SizedBox(height: 20),

                // 🔥 Activity Heatmap
                HeatmapSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                  activity: activity,
                  colorForValue: _colorForValue,
                ),

                const SizedBox(height: 28),

                // 🏆 Leaderboard Banner
                _buildLeaderboardBanner(context),

                const SizedBox(height: 28),

                // 📘 Today’s Trick Card
                _buildTodayTrickCard(theme),

                const SizedBox(height: 28),

                // 📈 Featured Actions
                _buildSectionHeader("Explore"),
                const SizedBox(height: 8),

                HomeCard(
                  title: "Performance Insights",
                  subtitle: "Track your accuracy & speed trends",
                  icon: Icons.trending_up_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformanceScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                HomeCard(
                  title: "Practice History",
                  subtitle: "Review your past quizzes & progress",
                  icon: Icons.history_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttemptsHistoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                HomeCard(
                  title: "Mixed Practice",
                  subtitle: "Build custom quizzes by topic & level",
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MixedQuizSetupScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // 🧠 Smart Practice Section
                _buildSectionHeader("Smart Practice"),
                const SizedBox(height: 8),
                const SmartPracticeSection(),

                const SizedBox(height: 28),

                // 🧮 Master Basics Section
                _buildSectionHeader("Master the Basics"),
                const SizedBox(height: 8),
                const MasterBasicsSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 👋 Personalized Welcome Header
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
          "Ready to sharpen your math reflexes today?",
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  /// 🏆 Leaderboard Motivation Banner
  Widget _buildLeaderboardBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.amber.shade600, Colors.orange.shade400],
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "You're #12 today! 🔥 Beat #11 with 5 more correct answers!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// 💡 Today’s Trick Mini Card
  Widget _buildTodayTrickCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "💡 Trick of the Day: To multiply by 11, add the digits and place in between!",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧭 Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    );
  }

  /// 🔄 Merge Offline (Hive) + Online (Firebase) Activity
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
