import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'learn_tile.dart';
import 'learn_detail_screen.dart';

/// 🧠 Learn Daily main screen — lists all core learning topics.
class LearnDailyScreen extends StatefulWidget {
  const LearnDailyScreen({super.key});

  @override
  State<LearnDailyScreen> createState() => _LearnDailyScreenState();
}

class _LearnDailyScreenState extends State<LearnDailyScreen> {
  Future<void> _refresh() async => setState(() {});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);

    final topics = [
      {'title': 'Tables', 'subtitle': 'Multiplication tables 1 to 100'},
      {'title': 'Squares', 'subtitle': 'Squares 1 to 100'},
      {'title': 'Cubes', 'subtitle': 'Cubes 1 to 100'},
      {'title': 'Square Roots', 'subtitle': '√1 to √100'},
      {'title': 'Cube Roots', 'subtitle': '∛1 to ∛100'},
      {
        'title': 'Percentage',
        'subtitle': 'Quick percent examples & improvements',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Daily'),
        backgroundColor: AppTheme.adaptiveCard(context),
        iconTheme: IconThemeData(color: AppTheme.adaptiveText(context)),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily revision & quick learning',
                style: TextStyle(
                  color: textColor.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final t = topics[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LearnTile(
                        title: t['title']!,
                        subtitle: t['subtitle']!,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LearnDetailScreen(topic: t['title']!),
                            ),
                          );
                          setState(() {}); // refresh tile status on return
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
