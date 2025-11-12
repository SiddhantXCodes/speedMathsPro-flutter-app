import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import '../services/hive_boxes.dart';

/// 🐝 In-App Debug Viewer for Hive Data
/// Lets you inspect all open Hive boxes and their contents.
class HiveDebugScreen extends StatefulWidget {
  const HiveDebugScreen({super.key});

  @override
  State<HiveDebugScreen> createState() => _HiveDebugScreenState();
}

class _HiveDebugScreenState extends State<HiveDebugScreen> {
  late List<Box> _openBoxes;

  @override
  void initState() {
    super.initState();
    _loadOpenBoxes();
  }

  void _loadOpenBoxes() {
    _openBoxes = [
      HiveBoxes.userProfileBox,
      HiveBoxes.userSettingsBox,
      HiveBoxes.practiceLogBox,
      HiveBoxes.questionHistoryBox,
      HiveBoxes.dailyScoreBox,
      HiveBoxes.streakData,
      HiveBoxes.dailyQuizMeta,
      HiveBoxes.leaderboardCacheBox,
      HiveBoxes.syncQueueBox,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🐝 Hive Data Debugger"),
        backgroundColor: theme.colorScheme.primary,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _openBoxes.isEmpty
          ? const Center(
              child: Text(
                "No boxes currently open.\nMake sure HiveBoxes.init() is called.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _openBoxes.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final box = _openBoxes[index];
                final entries = box.keys.map((key) {
                  final value = box.get(key);
                  return _buildEntryCard(theme, key, value);
                }).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: theme.cardColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      '📦 ${box.name} (${box.length} entries)',
                      style: theme.textTheme.titleMedium,
                    ),
                    children: entries.isNotEmpty
                        ? entries
                        : [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "No data in this box yet.",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEntryCard(ThemeData theme, dynamic key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔑 Key: $key",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "📄 Value: $value",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
