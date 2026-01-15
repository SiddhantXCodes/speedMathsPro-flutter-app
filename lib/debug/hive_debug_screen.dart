// lib/debug/hive_debug_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';

/// 🐝 Hive Debug Screen
/// Shows ONLY active Hive boxes from the new architecture
class HiveDebugScreen extends StatefulWidget {
  const HiveDebugScreen({super.key});

  @override
  State<HiveDebugScreen> createState() => _HiveDebugScreenState();
}

class _HiveDebugScreenState extends State<HiveDebugScreen> {
  final List<Box> _openBoxes = [];

  @override
  void initState() {
    super.initState();
    _loadBoxes();
  }

  void _loadBoxes() {
    _openIfExists('practice_logs');
    _openIfExists('question_history');
    _openIfExists('practice_scores');
    _openIfExists('mixed_scores');
    _openIfExists('ranked_scores');
    _openIfExists('topic_scores');
    _openIfExists('activity_data');
    _openIfExists('sync_queue'); // ranked leaderboard only
  }

  void _openIfExists(String name) {
    if (Hive.isBoxOpen(name)) {
      _openBoxes.add(Hive.box(name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppTheme.adaptiveText(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🐝 Hive Debugger"),
        backgroundColor: theme.colorScheme.primary,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _openBoxes.isEmpty
          ? Center(
              child: Text(
                "No Hive boxes are open.\nMake sure Hive.initFlutter() ran.",
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _openBoxes.length,
              itemBuilder: (context, index) {
                final box = _openBoxes[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "📦 ${box.name} (${box.length})",
                      style: theme.textTheme.titleMedium,
                    ),
                    children: box.isEmpty
                        ? const [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Box is empty",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ]
                        : box.keys.map((key) {
                            final value = box.get(key);
                            return _entry(theme, key, value);
                          }).toList(),
                  ),
                );
              },
            ),
    );
  }

  Widget _entry(ThemeData theme, dynamic key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔑 Key: $key",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "📄 Value:\n$value",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
