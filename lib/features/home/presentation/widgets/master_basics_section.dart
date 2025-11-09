import 'package:flutter/material.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';

/// 🧮 Master Basics Section — Topic-based offline practice cards
class MasterBasicsSection extends StatelessWidget {
  const MasterBasicsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final basics = [
      {'icon': Icons.add, 'title': 'Addition'},
      {'icon': Icons.remove, 'title': 'Subtraction'},
      {'icon': Icons.clear, 'title': 'Multiplication'},
      {'icon': Icons.percent, 'title': 'Division'},
      {'icon': Icons.calculate, 'title': 'Percentage'},
      {'icon': Icons.show_chart, 'title': 'Average'},
      {'icon': Icons.square_foot, 'title': 'Square'},
      {'icon': Icons.widgets_outlined, 'title': 'Cube'},
      {'icon': Icons.square_outlined, 'title': 'Square Root'},
      {'icon': Icons.data_exploration, 'title': 'Cube Root'},
      {'icon': Icons.table_chart, 'title': 'Tables'},
      {'icon': Icons.insights, 'title': 'Data Interpretation'},
    ];

    final textColor = AppTheme.adaptiveText(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Master Basics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: basics.map((item) {
            return _topicTile(
              context,
              item['icon'] as IconData,
              item['title'] as String,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showPracticeDialog(BuildContext context, String topic) {
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final minCtrl = TextEditingController(text: '5');
    final maxCtrl = TextEditingController(text: '30');
    double questionCount = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.adaptiveCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Practice $topic',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Range input fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecoration(context, 'Min number'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                      decoration: _inputDecoration(context, 'Max number'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question count slider
              Text(
                'Number of Questions: ${questionCount.toInt()}',
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
              Slider(
                value: questionCount,
                min: 5,
                max: 30,
                divisions: 5,
                activeColor: accent,
                onChanged: (value) => setState(() => questionCount = value),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final min = int.tryParse(minCtrl.text) ?? 0;
                    final max = int.tryParse(maxCtrl.text) ?? 100;
                    final count = questionCount.toInt();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          title: topic,
                          min: min,
                          max: max,
                          count: count,
                          mode: QuizMode.practice,
                          timeLimitSeconds: 0,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Start Practice',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
      filled: true,
      fillColor: colorScheme.surfaceVariant.withOpacity(0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  Widget _topicTile(BuildContext context, IconData icon, String title) {
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showPracticeDialog(context, title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.dividerColor.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: accent),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
