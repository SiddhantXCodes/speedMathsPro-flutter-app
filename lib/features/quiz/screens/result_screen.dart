// lib/features/quiz/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../theme/app_theme.dart';
import '../../performance/screens/performance_screen.dart';
import '../../home/screens/home_screen.dart';
import 'leaderboard_screen.dart';
import '../../../providers/performance_provider.dart';
import '../../../models/daily_score.dart';

class ResultScreen extends StatelessWidget {
  final int score; // ignored, firebase will be used
  final int timeTakenSeconds; // from quiz
  const ResultScreen({
    super.key,
    required this.score,
    required this.timeTakenSeconds,
  });

  // Today key
  String get todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // --------------------------------------------------------------------------
  // FETCH TODAY'S RANKED SCORE
  // --------------------------------------------------------------------------
  Future<DailyScore?> _loadTodayRankedScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection("ranked_attempts")
        .doc(user.uid)
        .collection("attempts")
        .doc(todayKey)
        .get();

    if (!doc.exists) return null;

    final d = doc.data()!;
    return DailyScore(
      score: d["score"],
      date: (d["timestamp"] as Timestamp).toDate(),
    );
  }

  // --------------------------------------------------------------------------
  // FETCH RANKED HISTORY (one per day)
  // --------------------------------------------------------------------------
  Future<List<DailyScore>> _loadRankedHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection("ranked_attempts")
        .doc(user.uid)
        .collection("attempts")
        .orderBy("timestamp", descending: true)
        .get();

    return snap.docs.map((doc) {
      final m = doc.data();
      return DailyScore(
        score: m["score"],
        date: (m["timestamp"] as Timestamp).toDate(),
      );
    }).toList();
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final surface = AppTheme.adaptiveCard(context);

    // Refresh performance after ranked attempt
    Future.microtask(() {
      Provider.of<PerformanceProvider>(context, listen: false).reloadAll();
    });

    final mins = (timeTakenSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (timeTakenSeconds % 60).toString().padLeft(2, '0');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: accent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              );
            },
          ),
          title: const Text("Ranked Result"),
          centerTitle: true,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ------------------------------------------------------------------
              // TODAY SCORE CARD (always from Firebase)
              // ------------------------------------------------------------------
              FutureBuilder<DailyScore?>(
                future: _loadTodayRankedScore(),
                builder: (context, snap) {
                  final todayScore = snap.data?.score ?? score;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your Today's Score",
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "$todayScore",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Time Taken: ${mins}m ${secs}s",
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------------
              // MAIN BUTTONS
              // ------------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text("Home"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.leaderboard_rounded),
                      label: const Text("Leaderboard"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: accent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------------------------
              // PERFORMANCE PAGE BUTTON
              // ------------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerformanceScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text("Performance Page"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent, width: 1.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ------------------------------------------------------------------
              // PAST ATTEMPTS — ALWAYS FROM FIREBASE
              // ------------------------------------------------------------------
              Expanded(
                child: FutureBuilder<List<DailyScore>>(
                  future: _loadRankedHistory(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final history = snapshot.data!;
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Past Attempts (${history.length})",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (history.isNotEmpty)
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
                              children: const [
                                Expanded(child: Text("Date")),
                                Expanded(
                                  child: Text(
                                    "Time",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Score",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8),

                        Expanded(
                          child: history.isEmpty
                              ? Center(
                                  child: Text(
                                    "No previous attempts",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: history.length,
                                  itemBuilder: (context, index) {
                                    final s = history[index];
                                    final isLast = index == 0;

                                    final dateStr = DateFormat(
                                      "MMM d, yy",
                                    ).format(s.date);
                                    final timeStr = DateFormat(
                                      "h:mm a",
                                    ).format(s.date);

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
                                                color: textColor.withOpacity(
                                                  0.7,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${s.score}",
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: accent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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
