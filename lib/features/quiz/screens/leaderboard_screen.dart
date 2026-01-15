// lib/features/quiz/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../providers/local_user_provider.dart';
import '../quiz_repository.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final QuizRepository _quizRepo = QuizRepository();

  String selectedTab = "daily";

  int? myDailyRank;
  int? myWeeklyRank;

  Map<String, dynamic>? myDailyData;
  Map<String, dynamic>? myWeeklyData;

  String get todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDailyRank();
      _fetchWeeklyRank();
    });
  }

  // -----------------------------------------------------------
  // DAILY RANK (DEVICE BASED)
  // -----------------------------------------------------------
  Future<void> _fetchDailyRank() async {
    final deviceId =
        context.read<LocalUserProvider>().deviceId;

    if (deviceId == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("daily_leaderboard")
        .doc(todayKey)
        .collection("entries")
        .orderBy("score", descending: true)
        .orderBy("timeTaken")
        .get();

    int rank = 1;
    myDailyRank = null;
    myDailyData = null;

    for (final doc in snap.docs) {
      final data = doc.data();
      if (data["deviceId"] == deviceId) {
        myDailyRank = rank;
        myDailyData = data;
        break;
      }
      rank++;
    }

    if (mounted) setState(() {});
  }

  // -----------------------------------------------------------
  // WEEKLY RANK
  // -----------------------------------------------------------
  Future<void> _fetchWeeklyRank() async {
    final deviceId =
        context.read<LocalUserProvider>().deviceId;

    if (deviceId == null) return;

    final list = await _fetchWeeklyLeaderboardList();

    int rank = 1;
    myWeeklyRank = null;
    myWeeklyData = null;

    for (final entry in list) {
      if (entry["deviceId"] == deviceId) {
        myWeeklyRank = rank;
        myWeeklyData = entry;
        break;
      }
      rank++;
    }

    if (mounted) setState(() {});
  }

  // -----------------------------------------------------------
  // WEEKLY = BEST OF LAST 7 DAYS
  // -----------------------------------------------------------
  Future<List<Map<String, dynamic>>> _fetchWeeklyLeaderboardList() async {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: i)));

    final Map<String, Map<String, dynamic>> bestByDevice = {};

    for (final d in days) {
      final key =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

      final snap = await FirebaseFirestore.instance
          .collection("daily_leaderboard")
          .doc(key)
          .collection("entries")
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final id = data["deviceId"];
        final score = data["score"] ?? 0;
        final time = data["timeTaken"] ?? 9999;

        if (!bestByDevice.containsKey(id) ||
            score > bestByDevice[id]!["score"] ||
            (score == bestByDevice[id]!["score"] &&
                time < bestByDevice[id]!["timeTaken"])) {
          bestByDevice[id] = {
            "deviceId": id,
            "username": data["username"] ?? "Player",
            "score": score,
            "timeTaken": time,
            "date": (data["timestamp"] as Timestamp?)?.toDate(),
          };
        }
      }
    }

    final list = bestByDevice.values.toList();

    list.sort((a, b) {
      final s = b["score"].compareTo(a["score"]);
      if (s != 0) return s;
      return a["timeTaken"].compareTo(b["timeTaken"]);
    });

    return list;
  }

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        backgroundColor: accent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _tabs(textColor, accent),
          const SizedBox(height: 12),
          Expanded(child: _tabContent(textColor, accent)),
          if (_yourRankSection() != null) _yourRankSection()!,
        ],
      ),
    );
  }

  Widget _tabs(Color textColor, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ["daily", "weekly"].map((t) {
        final selected = selectedTab == t;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(t.toUpperCase()),
            selected: selected,
            selectedColor: accent,
            onSelected: (_) => setState(() => selectedTab = t),
          ),
        );
      }).toList(),
    );
  }

  Widget _tabContent(Color textColor, Color accent) {
    if (selectedTab == "daily") {
      return StreamBuilder(
        stream: _quizRepo.getDailyLeaderboard(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snap.data!.docs.map((d) => d.data()).toList();
          return _buildList(list, textColor, accent);
        },
      );
    } else {
      return FutureBuilder(
        future: _fetchWeeklyLeaderboardList(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildList(snap.data!, textColor, accent);
        },
      );
    }
  }

  Widget _buildList(
      List<Map<String, dynamic>> list, Color textColor, Color accent) {
    if (list.isEmpty) {
      return const Center(child: Text("No results yet"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final e = list[i];
        return ListTile(
          leading: CircleAvatar(child: Text("${i + 1}")),
          title: Text(e["username"] ?? "Player"),
          trailing: Text("${e["score"]}"),
        );
      },
    );
  }

  Widget? _yourRankSection() {
    int? rank = selectedTab == "daily" ? myDailyRank : myWeeklyRank;
    if (rank == null) return null;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text("🔥 Your Rank: #$rank"),
    );
  }
}
