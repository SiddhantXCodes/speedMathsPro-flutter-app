import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class HeatmapSection extends StatelessWidget {
  final bool isDarkMode;
  final Map<DateTime, int> activity;
  final double cellSize;
  final double cellSpacing;
  final Color Function(int) colorForValue;

  const HeatmapSection({
    super.key,
    required this.isDarkMode,
    required this.activity,
    required this.cellSize,
    required this.cellSpacing,
    required this.colorForValue,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final bgColor = AppTheme.adaptiveCard(context);
    final now = DateTime.now();
    final year = now.year;

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    final allDays = _generateDays(startDate, endDate);
    final weeks = _splitIntoWeeks(allDays);
    final monthPositions = _getMonthPositions(weeks);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Practice Activity",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              Text(
                "$year",
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Heatmap grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int w = 0; w < weeks.length; w++) ...[
                  if (monthPositions.containsValue(w))
                    SizedBox(width: cellSpacing * 3),
                  Column(
                    children: [
                      for (int d = 0; d < 7; d++) ...[
                        _buildCell(context, weeks[w][d]),
                        SizedBox(height: cellSpacing),
                      ],
                    ],
                  ),
                  SizedBox(width: cellSpacing),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Month labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int w = 0; w < weeks.length; w++) ...[
                  SizedBox(
                    width: cellSize + cellSpacing,
                    child: Center(
                      child: monthPositions.containsValue(w)
                          ? Text(
                              _monthForWeek(monthPositions, w),
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor.withOpacity(0.6),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Legend
          Row(
            children: [
              Text('Less', style: TextStyle(fontSize: 12, color: textColor)),
              const SizedBox(width: 8),
              ...List.generate(4, (i) {
                final val = i + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorForValue(val),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text('More', style: TextStyle(fontSize: 12, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(BuildContext context, DateTime? date) {
    if (date == null) {
      return Container(width: cellSize, height: cellSize);
    }

    final normalized = DateTime(date.year, date.month, date.day);
    final value = activity[normalized] ?? 0;
    final color = colorForValue(value);

    return GestureDetector(
      onTap: value > 0
          ? () {
              final formatted = DateFormat('MMM d, yyyy').format(date);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.adaptiveCard(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  title: Text(
                    'Activity on $formatted',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.adaptiveText(context),
                    ),
                  ),
                  content: Text(
                    '$value practice sessions completed',
                    style: TextStyle(
                      color: AppTheme.adaptiveText(context).withOpacity(0.8),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  List<DateTime> _generateDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  List<List<DateTime?>> _splitIntoWeeks(List<DateTime> allDays) {
    final List<List<DateTime?>> weeks = [];
    List<DateTime?> current = List.filled(7, null);
    int offset = allDays.first.weekday - 1;
    int index = 0;
    for (int i = offset; i < 7 && index < allDays.length; i++) {
      current[i] = allDays[index++];
    }
    weeks.add(List.from(current));
    while (index < allDays.length) {
      current = List.filled(7, null);
      for (int i = 0; i < 7 && index < allDays.length; i++) {
        current[i] = allDays[index++];
      }
      weeks.add(List.from(current));
    }
    return weeks;
  }

  Map<int, int> _getMonthPositions(List<List<DateTime?>> weeks) {
    final map = <int, int>{};
    for (int w = 0; w < weeks.length; w++) {
      for (final d in weeks[w]) {
        if (d == null) continue;
        if (!map.containsKey(d.month)) map[d.month] = w;
      }
    }
    return map;
  }

  String _monthForWeek(Map<int, int> positions, int weekIndex) {
    final entry = positions.entries.firstWhere(
      (e) => e.value == weekIndex,
      orElse: () => const MapEntry(0, -1),
    );
    if (entry.key == 0) return '';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[entry.key];
  }
}
