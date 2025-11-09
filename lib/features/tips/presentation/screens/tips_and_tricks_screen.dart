import 'package:flutter/material.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../data/tips_data.dart';

/// 💡 Tips & Tricks Screen — All math theory in one place
class TipsAndTricksScreen extends StatelessWidget {
  const TipsAndTricksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final cardColor = AppTheme.adaptiveCard(context);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tips & Tricks"),
        centerTitle: true,
        backgroundColor: accent,
      ),
      backgroundColor: bgColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tipsData.keys.length,
        itemBuilder: (context, index) {
          final topic = tipsData.keys.elementAt(index);
          final tips = tipsData[topic]!;

          return Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: accent.withOpacity(0.1),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                iconColor: accent,
                collapsedIconColor: textColor.withOpacity(0.6),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  topic,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: tips.map((tip) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          size: 20,
                          color: accent.withOpacity(0.9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              color: textColor.withOpacity(0.9),
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
