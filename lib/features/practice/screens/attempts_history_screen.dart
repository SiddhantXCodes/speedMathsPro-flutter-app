// lib/features/practice/screens/attempts_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/practice_log.dart';
import '../../../providers/performance_provider.dart';
import '../../../providers/practice_log_provider.dart';
import '../../../theme/app_theme.dart';

/// AttemptsHistoryScreen
/// - Offline-only
/// - Practice attempts (Hive: PracticeLog)
/// - Daily ranked attempts (Hive: ranked_scores via PerformanceProvider)
class AttemptsHistoryScreen extends StatefulWidget {
  const AttemptsHistoryScreen({super.key});

  @override
  State<AttemptsHistoryScreen> createState() => _AttemptsHistoryScreenState();
}

class _AttemptsHistoryScreenState extends State<AttemptsHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _attempts = [];

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    setState(() => _isLoading = true);

    try {
      final practiceProvider = context.read<PracticeLogProvider>();
      final performanceProvider = context.read<PerformanceProvider>();

      final List<Map<String, dynamic>> merged = [];

      // ------------------------------------------------------------
      // PRACTICE ATTEMPTS (Hive → PracticeLog)
      // ------------------------------------------------------------
      final List<PracticeLog> practiceLogs =
          practiceProvider.getAllSessions().cast<PracticeLog>();

      for (final log in practiceLogs) {
        merged.add({
          'date': log.date,
          'score': log.score, // ✅ correct field
          'timeTakenSeconds': log.timeSpentSeconds, // ✅ correct field
          'mode': 'Practice',
        });
      }

      // ------------------------------------------------------------
      // RANKED ATTEMPTS (Hive → ranked_scores)
      // ------------------------------------------------------------
      performanceProvider.dailyScores.forEach((date, score) {
        merged.add({
          'date': date,
          'score': score,
          'timeTakenSeconds': 0, // ranked = score-only
          'mode': 'Ranked',
        });
      });

      // Newest first
      merged.sort((a, b) {
        final ad = a['date'] as DateTime;
        final bd = b['date'] as DateTime;
        return bd.compareTo(ad);
      });

      setState(() {
        _attempts = merged;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("⚠️ Failed to load attempts: $e");
      setState(() {
        _attempts = [];
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

    final lastAttempt = _attempts.isNotEmpty ? _attempts.first : null;

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
                  // ---------------- LAST ATTEMPT ----------------
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
                          Icon(Icons.check_circle_rounded,
                              color: accent, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            "Last Attempt (${lastAttempt['mode']})",
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
                            lastAttempt['timeTakenSeconds'] > 0
                                ? "Time: ${_formatDuration(lastAttempt['timeTakenSeconds'])} • ${DateFormat('MMM d, yyyy').format(lastAttempt['date'])}"
                                : DateFormat('MMM d, yyyy')
                                    .format(lastAttempt['date']),
                            style: TextStyle(
                              color: textColor.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ---------------- HEADER ----------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Past Attempts (${_attempts.length})",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---------------- LIST ----------------
                  Expanded(
                    child: _attempts.isEmpty
                        ? Center(
                            child: Text(
                              "No previous attempts",
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAttempts,
                            child: ListView.builder(
                              itemCount: _attempts.length,
                              itemBuilder: (context, index) {
                                final a = _attempts[index];
                                final date = a['date'] as DateTime;

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('MMM d, yy').format(date),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          DateFormat('h:mm a').format(date),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                textColor.withOpacity(0.7),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          a['timeTakenSeconds'] > 0
                                              ? "${a['score']} in ${a['timeTakenSeconds']}s"
                                              : "${a['score']}",
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: accent,
                                            fontWeight: FontWeight.bold,
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
}
