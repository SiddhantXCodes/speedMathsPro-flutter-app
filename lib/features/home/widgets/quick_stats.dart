// lib/features/home/widgets/quick_stats.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../auth/screens/login_screen.dart';
import '../../quiz/screens/daily_ranked_quiz_entry.dart';
import '../../quiz/screens/leaderboard_screen.dart';
import '../../performance/screens/performance_screen.dart';
import '../../../services/hive_service.dart';
import '../../../providers/performance_provider.dart';

// Popup import ✔
import '../../quiz/widgets/quiz_entry_popup.dart';

// Prefix to avoid conflict with Firebase Auth
import '../../auth/auth_provider.dart' as myauth;

class QuickStatsSection extends StatefulWidget {
  final bool isDarkMode;
  const QuickStatsSection({super.key, required this.isDarkMode});

  @override
  State<QuickStatsSection> createState() => _QuickStatsSectionState();
}

class _QuickStatsSectionState extends State<QuickStatsSection>
    with WidgetsBindingObserver {
  int? todayRank;
  int? allTimeRank;
  double avgScore = 0.0;
  bool _loading = true;
  bool _attemptedToday = false;

  int offlineSessions = 0;
  int offlineCorrect = 0;
  int offlineIncorrect = 0;
  double offlineAvgTime = 0.0;

  User? _lastUser;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<myauth.AuthProvider>().addListener(_authChanged);
      context.read<PerformanceProvider>().addListener(_dataChanged);

      _fetchStats();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    try {
      context.read<myauth.AuthProvider>().removeListener(_authChanged);
      context.read<PerformanceProvider>().removeListener(_dataChanged);
    } catch (_) {}

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchStats();
    }
  }

  @override
  void didUpdateWidget(covariant QuickStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchStats();
  }

  void _authChanged() {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.uid != _lastUser?.uid) {
      setState(() {
        todayRank = null;
        allTimeRank = null;
        avgScore = 0;
        _attemptedToday = false;

        offlineSessions = 0;
        offlineCorrect = 0;
        offlineIncorrect = 0;
        offlineAvgTime = 0;

        _loading = true;
      });

      _lastUser = user;
      _fetchStats();
    }
  }

  void _dataChanged() {
    _fetchStats();
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _fetchStats() async {
    if (!mounted || _isFetching) return;

    _isFetching = true;

    try {
      setState(() => _loading = true);

      // OFFLINE stats
      final localStats = HiveService.getStats() ?? {};
      offlineSessions = localStats['sessions'] ?? 0;
      offlineCorrect = localStats['totalCorrect'] ?? 0;
      offlineIncorrect = localStats['totalIncorrect'] ?? 0;
      offlineAvgTime = (localStats['avgTime'] ?? 0.0).toDouble();

      final user = FirebaseAuth.instance.currentUser;
      _lastUser = user;

      if (user == null) {
        setState(() => _loading = false);
        _isFetching = false;
        return;
      }

      // DAILY LEADERBOARD
      final firestore = FirebaseFirestore.instance;
      final todayKey = _dateKey(DateTime.now());

      final dailySnapshot = await firestore
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries')
          .orderBy('score', descending: true)
          .orderBy('timeTaken')
          .get();

      _attemptedToday = false;
      todayRank = null;

      int rank = 1;
      for (final doc in dailySnapshot.docs) {
        if (doc.id == user.uid) {
          todayRank = rank;
          _attemptedToday = true;
          break;
        }
        rank++;
      }

      // ALL-TIME
      final allSnap = await firestore
          .collection('alltime_leaderboard')
          .doc(user.uid)
          .get();

      if (allSnap.exists) {
        allTimeRank = await _getGlobalRank(user.uid);

        final data = allSnap.data()!;
        final quizzes = (data['quizzesTaken'] ?? 1).toDouble();
        final totalScore = (data['totalScore'] ?? 0).toDouble();
        avgScore = quizzes > 0 ? totalScore / quizzes : 0;
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint("⚠️ Error loading quick stats: $e");
      if (mounted) setState(() => _loading = false);
    }

    _isFetching = false;
  }

  Future<int?> _getGlobalRank(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('alltime_leaderboard')
          .orderBy('totalScore', descending: true)
          .get();

      int rank = 1;
      for (final doc in snapshot.docs) {
        if (doc.id == uid) return rank;
        rank++;
      }
    } catch (e) {
      debugPrint("⚠️ Rank fetch error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final accent = AppTheme.adaptiveAccent(context);
    final cardColor = AppTheme.adaptiveCard(context);
    final textColor = AppTheme.adaptiveText(context);

    if (_loading) {
      return Container(
        alignment: Alignment.center,
        height: 200,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final totalAttempts = offlineCorrect + offlineIncorrect;
    final accuracy = totalAttempts == 0
        ? 0
        : (offlineCorrect / totalAttempts) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quick Stats",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PerformanceScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.insights_rounded, color: accent, size: 20),
                label: Text(
                  "Performance",
                  style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Offline Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(
                Icons.school_rounded,
                "Sessions",
                "$offlineSessions",
                accent,
              ),
              _miniStat(
                Icons.check_circle_rounded,
                "Accuracy",
                "${accuracy.toStringAsFixed(1)}%",
                accent,
              ),
              _miniStat(
                Icons.timer_rounded,
                "Avg Time",
                "${offlineAvgTime.toStringAsFixed(1)}s",
                accent,
              ),
            ],
          ),

          const SizedBox(height: 20),

          user != null
              ? _buildRankedStats(accent)
              : _buildRankedGuest(accent, textColor),
        ],
      ),
    );
  }

  // ⭐ RANKED SECTION (UPDATED WITH POPUP)
  Widget _buildRankedStats(Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            _attemptedToday
                ? "🎯 You’ve completed today’s ranked quiz!"
                : "⚡ Take today’s Ranked Quiz and climb the leaderboard!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
          ),

          const SizedBox(height: 10),

          // 3 stat boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat(
                Icons.emoji_events_rounded,
                "Today Rank",
                todayRank != null ? "#$todayRank" : "—",
                accent,
              ),
              _miniStat(
                Icons.bar_chart_rounded,
                "All-Time",
                allTimeRank != null ? "#$allTimeRank" : "—",
                accent,
              ),
              _miniStat(
                Icons.speed_rounded,
                "Avg Score",
                avgScore.toStringAsFixed(1),
                accent,
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final perf = context.read<PerformanceProvider>();

                await perf.reloadAll();

                final playedToday = _attemptedToday;

                if (playedToday) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "🔥 You've already attempted today's ranked quiz!",
                      ),
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                } else {
                  // SHOW POPUP BEFORE STARTING QUIZ ✔
                  showQuizEntryPopup(
                    context: context,
                    title: "Daily Ranked Quiz",
                    infoLines: [
                      "10 questions fixed for all users.",
                      "Total time: 60 seconds.",
                      "Only 1 attempt allowed.",
                      "Leaderboard ranks depend on score & time.",
                      "If unsure, try Practice first.",
                    ],
                    onStart: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DailyRankedQuizEntry(),
                        ),
                      ).then((_) async {
                        await perf.reloadAll();
                        if (mounted) _fetchStats();
                      });
                    },
                  );
                }
              },
              icon: Icon(
                _attemptedToday
                    ? Icons.leaderboard_rounded
                    : Icons.flash_on_rounded,
                size: 20,
              ),
              label: Text(
                _attemptedToday
                    ? "View Leaderboard"
                    : "Take Today's Ranked Quiz",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankedGuest(Color accent, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            "🔥 Take the Daily Ranked Quiz to compete globally and track your streaks!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text("Login to Compete"),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accent, width: 1.3),
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String title, String value, Color accent) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: accent,
            fontSize: 14,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: accent.withOpacity(0.7)),
        ),
      ],
    );
  }
}
