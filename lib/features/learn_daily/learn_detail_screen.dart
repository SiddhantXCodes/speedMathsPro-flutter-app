import 'package:flutter/material.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../home/presentation/widgets/practice_bottom_sheet.dart';
import 'learn_repository.dart';
import 'learning_items.dart';
import 'widgets/learn_table_view.dart';
import 'widgets/learn_topic_list_view.dart';

class LearnDetailScreen extends StatefulWidget {
  final String topic;
  const LearnDetailScreen({super.key, required this.topic});

  @override
  State<LearnDetailScreen> createState() => _LearnDetailScreenState();
}

class _LearnDetailScreenState extends State<LearnDetailScreen> {
  late final LearnRepository _repo;
  late List<String> _items;
  bool _loading = true;
  bool _isReviewedToday = false;

  @override
  void initState() {
    super.initState();
    _repo = LearnRepository();
    _prepare();
  }

  Future<void> _prepare() async {
    _items = _generateItems(widget.topic);
    _isReviewedToday = await _repo.reviewedToday(widget.topic);
    setState(() => _loading = false);
  }

  Future<void> _toggleReviewed(bool? value) async {
    if (value == true) await _repo.markReviewed(widget.topic);
    setState(() => _isReviewedToday = value ?? false);
  }

  List<String> _generateItems(String topic) {
    switch (topic.toLowerCase()) {
      case 'tables':
      case 'tables 1-100':
        return LearningItems.tablesUpTo(upto: 100, maxMultiplier: 10);
      case 'squares':
        return LearningItems.squares(to: 100);
      case 'cubes':
        return LearningItems.cubes(to: 100);
      case 'square roots':
        return LearningItems.squareRoots(to: 100);
      case 'cube roots':
        return LearningItems.cubeRoots(to: 100);
      case 'percentage':
        return LearningItems.percentageExamples(from: 1, to: 20);
      default:
        return ['No data available for $topic'];
    }
  }

  void _startPractice(BuildContext context) {
    showPracticeBottomSheet(context, topic: widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);
    final isTableTopic = widget.topic.toLowerCase().contains('table');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic, style: TextStyle(color: textColor)),
        backgroundColor: AppTheme.adaptiveCard(context),
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ Header bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _isReviewedToday,
                            activeColor: accent,
                            onChanged: (v) => _toggleReviewed(v),
                          ),
                          Text(
                            _isReviewedToday
                                ? 'Reviewed today'
                                : 'Mark as reviewed',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text(
                          "Start Practice",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => _startPractice(context),
                      ),
                    ],
                  ),
                ),

                // ✅ Dynamic Content (Tables / Others)
                Expanded(
                  child: isTableTopic
                      ? LearnTableView(topic: widget.topic)
                      : LearnTopicListView(items: _items),
                ),
              ],
            ),
    );
  }
}
