// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedTab = "daily";
  final user = FirebaseAuth.instance.currentUser;

  String get todayKey {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  int? myRank;
  Map<String, dynamic>? myData;

  @override
  void initState() {
    super.initState();
    _fetchMyRank();
  }

  Future<void> _fetchMyRank() async {
    if (user == null) return;

    try {
      debugPrint("📡 Fetching from /daily_leaderboard/$todayKey/entries");

      final ref = FirebaseFirestore.instance
          .collection('daily_leaderboard')
          .doc(todayKey)
          .collection('entries')
          .orderBy('score', descending: true)
          .orderBy('timeTaken');

      final snap = await ref.get();
      debugPrint("✅ Found ${snap.docs.length} daily entries");

      int rank = 1;
      for (final doc in snap.docs) {
        debugPrint(
          "👤 ${doc.id} → ${(doc.data() as Map)['name']} (${(doc.data() as Map)['score']})",
        );
        if (doc.id == user!.uid) {
          setState(() {
            myRank = rank;
            myData = doc.data();
          });
          return;
        }
        rank++;
      }

      setState(() {
        myRank = null;
        myData = null;
      });
    } catch (e) {
      debugPrint("⚠️ Failed to fetch rank: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.adaptiveText(context);
    final accent = AppTheme.adaptiveAccent(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Leaderboard", style: TextStyle(color: textColor)),
        backgroundColor: accent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: "Refresh",
            onPressed: () {
              _fetchMyRank();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildTabs(context, textColor, accent),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedTab == "daily"
                  ? FirebaseFirestore.instance
                        .collection('daily_leaderboard')
                        .doc(todayKey)
                        .collection('entries')
                        .orderBy('score', descending: true)
                        .orderBy('timeTaken')
                        .limit(50)
                        .snapshots()
                  : FirebaseFirestore.instance
                        .collection('alltime_leaderboard')
                        .orderBy('totalScore', descending: true)
                        .limit(50)
                        .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      selectedTab == "daily"
                          ? "No one has played today yet!"
                          : "No leaderboard data yet.",
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final list = docs.map((e) {
                  final data = e.data() as Map<String, dynamic>;
                  return {
                    'id': e.id,
                    'name': data['name'] ?? 'Player',
                    'photoUrl': data['photoUrl'] ?? '',
                    'score': selectedTab == "daily"
                        ? (data['score'] ?? 0)
                        : (data['totalScore'] ?? 0),
                    'timeTaken': data['timeTaken'] ?? 0,
                    'correct': data['correct'] ?? 0,
                  };
                }).toList();

                return _buildLeaderboardList(context, list, textColor, accent);
              },
            ),
          ),
          if (user != null &&
              myData != null &&
              selectedTab == "daily" &&
              myRank != null)
            _buildYouCard(context, myRank!, myData!, accent, textColor),
        ],
      ),
    );
  }

  // 🏅 Tabs (Daily / All Time)
  Widget _buildTabs(BuildContext context, Color textColor, Color accent) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _tabButton("daily", "Daily", textColor, accent),
          _tabButton("all", "All Time", textColor, accent),
        ],
      ),
    );
  }

  Widget _tabButton(String id, String label, Color textColor, Color accent) {
    final isActive = selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = id;
          });
          _fetchMyRank();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : textColor.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🏆 Leaderboard List
  Widget _buildLeaderboardList(
    BuildContext context,
    List<Map<String, dynamic>> list,
    Color textColor,
    Color accent,
  ) {
    final top3 = list.take(3).toList();
    final others = list.length > 3 ? list.sublist(3) : [];

    return Column(
      children: [
        if (top3.isNotEmpty) _buildTopThree(context, top3),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90, top: 12),
            itemCount: others.length,
            itemBuilder: (context, index) {
              final entry = others[index];
              final isYou = user != null && entry['id'] == user!.uid;
              final rank = index + 4;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isYou
                      ? accent.withOpacity(0.12)
                      : Theme.of(context).cardColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isYou ? accent : accent.withOpacity(0.2),
                      child: Text(
                        "$rank",
                        style: TextStyle(
                          color: isYou ? Colors.white : textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          (entry['photoUrl']?.toString().isNotEmpty ?? false)
                          ? NetworkImage(entry['photoUrl'])
                          : null,
                      backgroundColor: accent.withOpacity(0.15),
                      child:
                          (entry['photoUrl'] == null ||
                              entry['photoUrl'].toString().isEmpty)
                          ? Text(
                              (entry['name'] ?? 'U')[0].toUpperCase(),
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry['name'],
                        style: TextStyle(
                          fontWeight: isYou ? FontWeight.bold : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      "${entry['score']} pts",
                      style: TextStyle(
                        color: textColor.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
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
  }

  // 🥇 Top 3 Players Layout (ADDED)
  Widget _buildTopThree(BuildContext context, List<Map<String, dynamic>> list) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (list.length > 1) _buildAvatar(context, list[1], 2, size: 65),
          _buildAvatar(context, list[0], 1, size: 80, crown: true),
          if (list.length > 2) _buildAvatar(context, list[2], 3, size: 65),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    Map<String, dynamic> data,
    int rank, {
    required double size,
    bool crown = false,
  }) {
    final textColor = AppTheme.adaptiveText(context);
    final color = rank == 1
        ? AppTheme.gold
        : rank == 2
        ? AppTheme.silver
        : rank == 3
        ? AppTheme.bronze
        : AppTheme.adaptiveAccent(context);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (crown)
              Positioned(
                top: -20,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: color,
                  size: 30,
                ),
              ),
            CircleAvatar(
              radius: size / 2,
              backgroundImage:
                  (data['photoUrl']?.toString().isNotEmpty ?? false)
                  ? NetworkImage(data['photoUrl'])
                  : null,
              backgroundColor: color.withOpacity(0.15),
              child:
                  (data['photoUrl'] == null ||
                      data['photoUrl'].toString().isEmpty)
                  ? Text(
                      (data['name'] ?? 'P')[0].toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "#$rank",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "${data['score']} pts",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.adaptiveText(context).withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // 👤 Your rank card
  Widget _buildYouCard(
    BuildContext context,
    int rank,
    Map data,
    Color accent,
    Color textColor,
  ) {
    final score = data['score'] ?? 0;
    final correct = data['correct'] ?? 0;
    final time = data['timeTaken'] ?? 0;
    final m = (time ~/ 60).toString().padLeft(2, '0');
    final s = (time % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accent,
                backgroundImage: (user?.photoURL != null)
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: (user?.photoURL == null)
                    ? Text(
                        (user?.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "You",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Rank: #$rank | $score pts | $correct correct | ⏱ $m:$s",
                    style: TextStyle(color: textColor.withOpacity(0.75)),
                  ),
                ],
              ),
            ],
          ),
          Icon(Icons.emoji_events_rounded, color: accent, size: 28),
        ],
      ),
    );
  }
}
