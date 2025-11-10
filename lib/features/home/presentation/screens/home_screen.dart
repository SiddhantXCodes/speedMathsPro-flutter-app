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

// 📊 Feature Screens
import '../../../performance/presentation/screens/performance_screen.dart';
import '../../../quiz/presentation/screens/setup/mixed_quiz_setup_screen.dart';
import '../../../practice/presentation/screens/attempts_history_screen.dart';

/// 🏠 Home Screen — Unified Dashboard Entry Point
/// Displays Quick Stats, Heatmap, Insights, and Smart Practice sections.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  // kept as constants in case you want to re-enable size parameters later
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

  /// 🔄 Refresh local + online stats when returning to home
  Future<void> _refreshActivityData() async {
    try {
      final performance = Provider.of<PerformanceProvider>(
        context,
        listen: false,
      );
      await performance.loadFromLocal(forceReload: true);
      // No need to call setState(); Provider notifies automatically
    } catch (e) {
      debugPrint("⚠️ Failed to refresh data: $e");
    }
  }

  /// 🎨 Heatmap intensity color scale
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

    // 🧩 Combine online (ranked) + offline (practice) activity
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
                const SizedBox(height: 12),

                /// ⚡ Quick Stats (Ranked + Practice)
                QuickStatsSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                ),

                const SizedBox(height: 20),

                /// 🔥 Activity Heatmap (Offline + Online)
                // NOTE: HeatmapSection signature changed — it no longer accepts
                // cellSize/cellSpacing named params. Pass activity + colorForValue.
                HeatmapSection(
                  isDarkMode: theme.brightness == Brightness.dark,
                  activity: activity,
                  colorForValue: _colorForValue,
                ),

                const SizedBox(height: 24),

                /// 📈 Performance Insights
                HomeCard(
                  title: "Performance Insights",
                  subtitle: "Track your progress & accuracy trends",
                  icon: Icons.trending_up_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformanceScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🧾 Practice History
                HomeCard(
                  title: "Practice History",
                  subtitle: "Review all your past attempts (offline + online)",
                  icon: Icons.history_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttemptsHistoryScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 🎯 Mixed Practice Entry
                HomeCard(
                  title: "Mixed Practice",
                  subtitle: "Custom multi-topic quiz builder",
                  icon: Icons.auto_awesome_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MixedQuizSetupScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🧠 Smart Practice Section (Ranked + Tips)
                const SmartPracticeSection(),

                const SizedBox(height: 24),

                /// 🧮 Master Basics Section (Offline Topics)
                const MasterBasicsSection(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
