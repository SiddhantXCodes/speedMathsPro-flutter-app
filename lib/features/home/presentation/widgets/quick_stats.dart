import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../presentation/theme/app_theme.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../quiz/presentation/screens/daily_ranked_quiz_entry.dart';
import '../../../quiz/presentation/screens/leaderboard_screen.dart';
import '../../../performance/presentation/screens/performance_screen.dart';
import '../../../../core/services/hive_service.dart';

/// ⚡ Unified Quick Stats Section (Hybrid Offline + Online)
/// Displays user’s offline stats and ranked (online) quiz performance.
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

  // --- Offline stats ---
  int offlineSessions = 0;
  int offlineCorrect = 0;
  int offlineIncorrect = 0;
  double offlineAvgTime = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchStats();
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _fetchStats() async {
    try {
      final localStats = HiveService.getStats() ?? {};
      offlineSessions = (localStats['sessions'] ?? 0) as int;
      offlineCorrect = (localStats['totalCorrect'] ?? 0) as int;
      offlineIncorrect = (localStats['totalIncorrect'] ?? 0) as int;
      offlineAvgTime = (localStats['avgTime'] ?? 0.0) as double;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final todayKey = _dateKey(DateTime.now());

      // ---- Fetch today's leaderboard rank ----
      final dailyRef = firestore
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries');
      final snapshot = await dailyRef
          .orderBy('score', descending: true)
          .orderBy('timeTaken')
          .get();

      int rank = 1;
      todayRank = null;
      _attemptedToday = false;
      for (final doc in snapshot.docs) {
        if (doc.id == user.uid) {
          todayRank = rank;
          _attemptedToday = true;
          break;
        }
        rank++;
      }

      // ---- Fetch all-time rank ----
      final allRef = firestore.collection('alltime_leaderboard').doc(user.uid);
      final allSnap = await allRef.get();

      if (allSnap.exists) {
        allTimeRank = await _getGlobalRank(user.uid);
        final data = allSnap.data()!;
        final quizzes = (data['quizzesTaken'] ?? 1).toDouble();
        final totalScore = (data['totalScore'] ?? 0).toDouble();
        avgScore = quizzes > 0 ? totalScore / quizzes : 0;
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint("⚠️ Error loading stats: $e");
      if (mounted) setState(() => _loading = false);
    }
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
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final totalAttempts = offlineCorrect + offlineIncorrect;
    final accuracy = totalAttempts > 0
        ? (offlineCorrect / totalAttempts) * 100
        : 0;

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
          // 🧭 Header
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
          const SizedBox(height: 12),

          // 📊 Offline Stats
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

          // ⚡ Ranked Quiz Section
          if (user != null)
            _buildRankedStats(accent)
          else
            _buildRankedGuest(accent, textColor, context),
        ],
      ),
    );
  }

  // --- Ranked Stats for Logged-in Users ---
  Widget _buildRankedStats(Color accent) {
    return Container(
      width: double.infinity,
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
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
              onPressed: () {
                if (_attemptedToday) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeaderboardScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DailyRankedQuizEntry(),
                    ),
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
                    : "Take Today’s Ranked Quiz",
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

  // --- Ranked Section for Guests (only login now) ---
  Widget _buildRankedGuest(
    Color accent,
    Color textColor,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
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

  // --- Mini Stat Widget ---
  Widget _miniStat(IconData icon, String title, String value, Color accent) {
    return Column(
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: accent,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: accent.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}
