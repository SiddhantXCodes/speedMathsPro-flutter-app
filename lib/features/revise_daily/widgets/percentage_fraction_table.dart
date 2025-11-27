import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class PercentageFractionTable extends StatelessWidget {
  final List<String> items;

  const PercentageFractionTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final theme = Theme.of(context);

    final rows = items
        .map((entry) => entry.split('→').map((s) => s.trim()).toList())
        .where((parts) => parts.length == 3)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeaderRow(context, textColor, theme),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final r = rows[index];
                  final bool isOdd = index % 2 == 1;
                  return _buildDataRow(
                    context,
                    r[0],
                    r[1],
                    r[2],
                    textColor,
                    theme,
                    isOdd,
                    index,
                    rows.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER ---------------------------------------------------------
  Widget _buildHeaderRow(
    BuildContext context,
    Color textColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _headerCell("Fraction", flex: 1, textColor: textColor),
          _headerCell("Mixed %", flex: 2, textColor: textColor),
          _headerCell("Percent", flex: 1, textColor: textColor),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    required int flex,
    required Color textColor,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor.withOpacity(0.9),
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ROWS ---------------------------------------------------------------
  Widget _buildDataRow(
    BuildContext context,
    String f,
    String mixed,
    String pct,
    Color textColor,
    ThemeData theme,
    bool isOdd,
    int index,
    int totalRows,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: isOdd
            ? theme.colorScheme.surface.withOpacity(0.05)
            : theme.colorScheme.surface.withOpacity(0.15),
        borderRadius: BorderRadius.vertical(
          bottom: index == totalRows - 1
              ? const Radius.circular(16)
              : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          _tableCell(f, flex: 1, textColor: textColor),
          _tableCell(mixed, flex: 2, textColor: textColor),
          _tableCell(pct, flex: 1, textColor: textColor),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text, {
    required int flex,
    required Color textColor,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}
