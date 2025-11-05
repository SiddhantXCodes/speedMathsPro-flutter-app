import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/quick_stats.dart';
import '../widgets/heatmap_section.dart';
import '../widgets/features_section.dart';
import '../providers/performance_provider.dart';
import '../providers/practice_log_provider.dart';
import '../theme/app_theme.dart';
import '../app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  bool isDarkMode = false;
  int userStreak = 10;
  bool didToday = false;

  final double cellSize = 12;
  final double cellSpacing = 4;

  Color _colorForValue(int value) {
    switch (value.clamp(0, 4)) {
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

  void _toggleToday() async {
    final todayKey = DateTime.now();

    setState(() {
      didToday = !didToday;
      userStreak = didToday ? userStreak + 1 : max(0, userStreak - 1);
    });

    try {
      final logProvider = Provider.of<PracticeLogProvider>(
        context,
        listen: false,
      );

      if (didToday) {
        await logProvider.addSession(
          topic: "Manual Practice",
          score: 1,
          total: 1,
          timeSpentSeconds: 60,
        );
      } else {
        await logProvider.removeSession(todayKey);
      }
    } catch (e) {
      debugPrint("⚠️ Failed to update today's streak: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppTheme.adaptiveText(context);
    final bgColor = theme.scaffoldBackgroundColor;

    final practiceLog = Provider.of<PracticeLogProvider>(context);
    final activity = practiceLog.getActivityMap();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopBar(
          userStreak: userStreak, // or pass your streak variable here
          onToggleToday: _toggleToday,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              QuickStatsSection(
                isDarkMode: theme.brightness == Brightness.dark,
              ),
              const SizedBox(height: 20),
              HeatmapSection(
                isDarkMode: theme.brightness == Brightness.dark,
                activity: activity,
                cellSize: cellSize,
                cellSpacing: cellSpacing,
                colorForValue: _colorForValue,
              ),
              const SizedBox(height: 24),
              FeaturesSection(isDarkMode: theme.brightness == Brightness.dark),
            ],
          ),
        ),
      ),
    );
  }
}
