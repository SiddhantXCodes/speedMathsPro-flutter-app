import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LearnTableView extends StatefulWidget {
  final String topic;
  const LearnTableView({super.key, required this.topic});

  @override
  State<LearnTableView> createState() => _LearnTableViewState();
}

class _LearnTableViewState extends State<LearnTableView> {
  late final PageController _pageController;
  late List<Map<String, dynamic>> groups;
  int selectedGroupIndex = 0;

  static const double _leftColumnWidth = 70;
  static const int _tablesPerGroup = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Generate groups of 5
    groups = List.generate(20, (i) {
      final start = (i * _tablesPerGroup) + 1;
      final end = start + _tablesPerGroup - 1;
      return {'label': '$start–$end', 'start': start, 'end': end};
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildLeftColumn(accent),
              _buildPagedTables(context, accent, textColor),
            ],
          ),
        ),
        _buildBottomChips(accent, textColor),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LEFT COLUMN — uses dynamic height also
  // ---------------------------------------------------------------------------

  Widget _buildLeftColumn(Color accent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellHeight = constraints.maxHeight / 11;

        return Container(
          width: _leftColumnWidth,
          color: accent.withOpacity(0.85),
          child: Column(
            children: [
              // Header: ×
              Container(
                height: cellHeight,
                alignment: Alignment.center,
                color: accent.withOpacity(0.15),
                child: Text(
                  "×",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: cellHeight * 0.40,
                  ),
                ),
              ),

              // Rows x1–x10
              for (int i = 1; i <= 10; i++)
                Container(
                  height: cellHeight,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  child: Text(
                    "x$i",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: cellHeight * 0.30,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT — PAGEVIEW (dynamic height applied)
  // ---------------------------------------------------------------------------

  Widget _buildPagedTables(
    BuildContext context,
    Color accent,
    Color textColor,
  ) {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: groups.length,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (i) => setState(() => selectedGroupIndex = i),
        itemBuilder: (context, index) {
          final start = groups[index]['start'];
          final end = groups[index]['end'];

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cellHeight = constraints.maxHeight / 11;

              return Row(
                children: [
                  for (int n = start; n <= end; n++)
                    Expanded(
                      child: _buildTableColumn(
                        context,
                        n,
                        textColor,
                        accent,
                        constraints.maxWidth / 5,
                        cellHeight,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT — SINGLE TABLE COLUMN WITH DYNAMIC HEIGHT
  // ---------------------------------------------------------------------------

  Widget _buildTableColumn(
    BuildContext context,
    int number,
    Color textColor,
    Color accent,
    double width,
    double cellHeight,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header cell
        Container(
          height: cellHeight,
          alignment: Alignment.center,
          color: accent.withOpacity(0.15),
          child: Text(
            "$number",
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.bold,
              fontSize: cellHeight * 0.30,
            ),
          ),
        ),

        // x1–x10 rows
        for (int i = 1; i <= 10; i++)
          Container(
            height: cellHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i.isEven
                  ? theme.colorScheme.surface.withOpacity(0.96)
                  : theme.colorScheme.surface.withOpacity(0.90),
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.10),
                  width: 0.4,
                ),
              ),
            ),
            child: Text(
              "${number * i}",
              style: TextStyle(
                color: textColor,
                fontSize: cellHeight * 0.32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM CHIPS
  // ---------------------------------------------------------------------------

  Widget _buildBottomChips(Color accent, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: textColor.withOpacity(0.08), width: 0.6),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: groups.asMap().entries.map((entry) {
            final i = entry.key;
            final label = entry.value['label'];
            final bool selected = i == selectedGroupIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                  setState(() => selectedGroupIndex = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? accent : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : textColor.withOpacity(0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
