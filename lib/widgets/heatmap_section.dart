import 'package:flutter/material.dart';

class HeatmapSection extends StatelessWidget {
  final bool isDarkMode;
  final int year;
  final List<List<DateTime?>> weeks;
  final Map<int, int> monthPositions;
  final double cellSize;
  final double cellSpacing;
  final Map<DateTime, int> activity;
  final Color Function(int) colorForValue;

  const HeatmapSection({
    super.key,
    required this.isDarkMode,
    required this.year,
    required this.weeks,
    required this.monthPositions,
    required this.cellSize,
    required this.cellSpacing,
    required this.activity,
    required this.colorForValue,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final weekCount = weeks.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
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
                'Your Practice Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              DropdownButton<int>(
                value: year,
                underline: const SizedBox(),
                items: [year, year - 1, year - 2]
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text('$y', style: TextStyle(color: textColor)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Heatmap grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int w = 0; w < weekCount; w++) ...[
                  Column(
                    children: [
                      for (int d = 0; d < 7; d++) ...[
                        _buildCell(weeks[w][d]),
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
                for (int w = 0; w < weekCount; w++) ...[
                  SizedBox(
                    width: cellSize,
                    child: Center(
                      child: monthPositions.containsValue(w)
                          ? Text(
                              _monthForWeek(monthPositions, w),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(width: cellSpacing),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Legend
          Row(
            children: [
              const Text('Less', style: TextStyle(fontSize: 12)),
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
              const Text('More', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(DateTime? date) {
    if (date == null) {
      return Container(width: cellSize, height: cellSize);
    }
    final key = DateTime(date.year, date.month, date.day);
    final int val = activity[key] ?? 0;
    final color = colorForValue(val);
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  String _monthForWeek(Map<int, int> monthPositions, int weekIndex) {
    final entry = monthPositions.entries.firstWhere(
      (e) => e.value == weekIndex,
      orElse: () => const MapEntry(0, -1),
    );
    if (entry.key == 0) return '';
    const names = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return names[entry.key];
  }
}
