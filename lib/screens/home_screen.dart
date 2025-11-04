import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/top_bar.dart';
import '../widgets/quick_stats.dart';
import '../widgets/heatmap_section.dart';
import '../widgets/features_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  int userStreak = 10;
  bool didToday = false;

  final Map<DateTime, int> _activity = {
    for (int i = 0; i < 365; i++)
      DateTime(DateTime.now().year, 1, 1).add(Duration(days: i)): (i % 11 == 0)
          ? 4
          : (i % 7 == 0)
          ? 2
          : (i % 5 == 0 ? 1 : 0),
  };

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

  List<List<DateTime?>> _generateYearWeeks(int year) {
    final first = DateTime(year, 1, 1);
    final last = DateTime(year, 12, 31);
    int pad = first.weekday - 1;
    List<DateTime?> currentWeek = List<DateTime?>.filled(7, null);
    List<List<DateTime?>> weeks = [];

    int dayIndex = 0;
    DateTime day = first;
    for (int i = pad; i < 7; i++) {
      currentWeek[i] = day;
      day = day.add(const Duration(days: 1));
    }
    weeks.add(List<DateTime?>.from(currentWeek));

    while (!day.isAfter(last)) {
      currentWeek = List<DateTime?>.filled(7, null);
      for (int i = 0; i < 7 && !day.isAfter(last); i++) {
        currentWeek[i] = day;
        day = day.add(const Duration(days: 1));
      }
      weeks.add(List<DateTime?>.from(currentWeek));
    }
    return weeks;
  }

  Map<int, int> _monthFirstWeekIndex(List<List<DateTime?>> weeks) {
    final map = <int, int>{};
    for (int w = 0; w < weeks.length; w++) {
      for (final d in weeks[w]) {
        if (d == null) continue;
        final m = d.month;
        if (!map.containsKey(m)) map[m] = w;
      }
    }
    return map;
  }

  void _toggleToday() {
    final todayKey = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    setState(() {
      didToday = !didToday;
      if (didToday) {
        userStreak += 1;
        _activity[todayKey] = ((_activity[todayKey] ?? 0) + 2).clamp(0, 4);
      } else {
        userStreak = max(0, userStreak - 1);
        _activity[todayKey] = ((_activity[todayKey] ?? 0) - 2).clamp(0, 4);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final weeks = _generateYearWeeks(year);
    final monthPositions = _monthFirstWeekIndex(weeks);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: TopBar(
          isDarkMode: isDarkMode,
          userStreak: userStreak,
          onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
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
              QuickStatsSection(isDarkMode: false),
              const SizedBox(height: 20),
              HeatmapSection(
                isDarkMode: isDarkMode,
                year: year,
                weeks: weeks,
                monthPositions: monthPositions,
                cellSize: cellSize,
                cellSpacing: cellSpacing,
                activity: _activity,
                colorForValue: _colorForValue,
              ),
              const SizedBox(height: 24),
              FeaturesSection(isDarkMode: isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
}
