import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../learn_repository.dart';
import '../learning_items.dart';
import '../widgets/learn_table_view.dart';
import '../widgets/learn_topic_list_view.dart';
import '../widgets/percentage_fraction_table.dart'; // ⬅ make sure this import exists

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

  @override
  void initState() {
    super.initState();
    _repo = LearnRepository();
    _prepare();
  }

  Future<void> _prepare() async {
    _items = _generateItems(widget.topic);
    setState(() => _loading = false);
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
        // ⬅ Return the raw string list (not widget)
        return LearningItems.percentageExamples(from: 2, to: 50);

      default:
        return ['No data available for $topic'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final theme = Theme.of(context);

    final bool isTableTopic = widget.topic.toLowerCase().contains('table');
    final bool isPercentage = widget.topic.toLowerCase() == 'percentage';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          widget.topic,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          // 1️⃣ TABLE VIEW (no padding)
          : isTableTopic
          ? LearnTableView(topic: widget.topic)
          // 2️⃣ PERCENTAGE → show 3-column table widget
          : isPercentage
          ? PercentageFractionTable(items: _items)
          // 3️⃣ NORMAL TOPIC LIST WITH PADDING
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: LearnTopicListView(items: _items),
            ),
    );
  }
}
