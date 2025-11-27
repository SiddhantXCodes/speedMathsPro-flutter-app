// lib/features/practice/screens/attempts_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/performance_provider.dart';
import '../../../providers/practice_log_provider.dart';
import '../../../theme/app_theme.dart';

/// AttemptsHistoryScreen
/// - Merges offline practice (Hive) + online ranked (Firestore)
/// - Keeps the exact visual style of PracticeOverviewScreen's past attempts list
class AttemptsHistoryScreen extends StatefulWidget {
  const AttemptsHistoryScreen({super.key});

  @override
  State<AttemptsHistoryScreen> createState() => _AttemptsHistoryScreenState();
}

class _AttemptsHistoryScreenState extends State<AttemptsHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _mergedAttempts = [];

  @override
  void initState() {
    super.initState();
    _loadAllAttempts();
  }

  Future<void> _loadAllAttempts() async {
    setState(() => _isLoading = true);
    try {
      final practiceProvider = context.read<PracticeLogProvider>();
      final performanceProvider = context.read<PerformanceProvider>();

      // --- fetch raw sources (could be model objects or maps) ---
      final rawOffline = practiceProvider.getAllSessions(); // offline (Hive)
      final rawOnline = await performanceProvider
          .fetchOnlineAttempts(); // online (Firestore)

      final List<Map<String, dynamic>> normalized = [];

      // Normalize offline items
      for (final item in rawOffline) {
        // Support both model objects (having properties) and plain maps
        try {
          DateTime? date;
          int score = 0;
          int timeTakenSeconds = 0;
          String mode = 'Practice';

          if (item is Map) {
            // common map keys
            date = (item['date'] ?? item['timestamp']) as DateTime?;
            score =
                (item['score'] ?? item['points'] ?? item['correct'] ?? 0)
                    as int;
            // prefer explicit timeTakenSeconds, fallback to timeTaken or time
            timeTakenSeconds =
                (item['timeTakenSeconds'] ??
                        item['timeTaken'] ??
                        item['durationSeconds'] ??
                        0)
                    as int;
            mode = (item['category'] ?? item['mode'] ?? 'Practice').toString();
          }

          normalized.add({
            'score': score,
            'timeTakenSeconds': timeTakenSeconds,
            'date': date ?? DateTime.now(),
            'mode': mode,
          });
        } catch (e) {
          debugPrint('⚠️ normalize offline item failed: $e');
        }
      }

      // Normalize online items
      for (final item in rawOnline) {
        try {
          DateTime? date;
          int score = 0;
          int timeTakenSeconds = 0;
          String mode = 'Ranked';

          if (item is Map) {
            date =
                (item['date'] ?? item['timestamp'] ?? item['ts']) as DateTime?;
            // Firestore may send Timestamp — handle if needed
            if (date == null && item['timestamp'] is dynamic) {
              final ts = item['timestamp'];
              try {
                // Firestore Timestamp -> DateTime
                // Many SDKs return a DateTime already; if it's a Timestamp, user code should convert.
                date = ts;
              } catch (_) {}
            }
            score = (item['score'] ?? item['points'] ?? 0) as int;
            timeTakenSeconds =
                (item['timeTakenSeconds'] ??
                        item['timeTaken'] ??
                        item['timeTakenSecs'] ??
                        0)
                    as int;
            mode = (item['category'] ?? item['mode'] ?? 'Ranked').toString();
          }

          normalized.add({
            'score': score,
            'timeTakenSeconds': timeTakenSeconds,
            'date': date ?? DateTime.now(),
            'mode': mode,
          });
        } catch (e) {
          debugPrint('⚠️ normalize online item failed: $e');
        }
      }

      // Sort newest first
      normalized.sort((a, b) {
        final ad = a['date'] as DateTime? ?? DateTime.now();
        final bd = b['date'] as DateTime? ?? DateTime.now();
        return bd.compareTo(ad);
      });

      setState(() {
        _mergedAttempts = normalized;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to load attempts: $e');
      setState(() {
        _mergedAttempts = [];
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final surface = AppTheme.adaptiveCard(context);

    final attempts = _mergedAttempts;
    final lastAttempt = attempts.isNotEmpty ? attempts.first : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: accent,
        centerTitle: true,
        title: const Text("Attempts History"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(accent),
                ),
              )
            : Column(
                children: [
                  // LAST ATTEMPT CARD (same visual as PracticeOverview)
                  if (lastAttempt != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: accent,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Last Attempt",
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${lastAttempt['score']}",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lastAttempt['timeTakenSeconds'] != null &&
                                    (lastAttempt['timeTakenSeconds'] as int) > 0
                                ? "Time: ${_formatDuration(lastAttempt['timeTakenSeconds'] as int)} • ${DateFormat('MMM d, yyyy').format(lastAttempt['date'] as DateTime)}"
                                : "${DateFormat('MMM d, yyyy').format(lastAttempt['date'] as DateTime)}",
                            style: TextStyle(
                              color: textColor.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ] else ...[
                    // No attempts UI (keeps the same simple messaging)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Attempts",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You have no attempts yet. Start practicing or join the daily ranked quiz!",
                            style: TextStyle(color: textColor.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Past Attempts Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Past Attempts (${attempts.length})",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // HEADER ROW (same style)
                  if (attempts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _header("Date", textColor)),
                          Expanded(
                            child: Text(
                              "Time",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Score",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Attempts list
                  Expanded(
                    child: attempts.isEmpty
                        ? Center(
                            child: Text(
                              "No previous attempts",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAllAttempts,
                            child: ListView.builder(
                              itemCount: attempts.length,
                              itemBuilder: (context, index) {
                                final a = attempts[index];
                                final isLast = index == 0;

                                final date = a['date'] as DateTime;
                                final dateStr = DateFormat(
                                  "MMM d, yy",
                                ).format(date);
                                final timeStr = DateFormat(
                                  "h:mm a",
                                ).format(date);

                                final score = a['score'] ?? 0;
                                final timeTaken = a['timeTakenSeconds'] ?? 0;

                                final mixedResult = timeTaken > 0
                                    ? "$score in ${timeTaken}s"
                                    : "$score";

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isLast
                                        ? accent.withOpacity(0.08)
                                        : surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLast
                                          ? accent.withOpacity(0.15)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          timeStr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: textColor.withOpacity(0.7),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          // same behaviour as PracticeOverview: if time present show "score in secs" else just score
                                          timeTaken > 0
                                              ? mixedResult
                                              : "$score",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: timeTaken > 0 ? 15 : 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _header(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color.withOpacity(0.8),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}
