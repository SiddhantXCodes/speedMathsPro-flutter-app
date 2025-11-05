import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboard = [];
  int? myScore;
  String? todayKey;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    todayKey = DateTime.now().toIso8601String().substring(0, 10);
    myScore = prefs.getInt('daily_score_$todayKey') ?? 0;

    // Mock data (global leaderboard)
    final random = Random();
    leaderboard = List.generate(15, (i) {
      return {
        'name': 'User_${1000 + i}',
        'score': random.nextInt(120) - 20,
        'time':
            '${5 + random.nextInt(2)}:${random.nextInt(60).toString().padLeft(2, '0')}',
      };
    });

    // Add current user to list
    leaderboard.add({'name': 'You', 'score': myScore ?? 0, 'time': '07:00'});

    // Sort by score descending
    leaderboard.sort((a, b) => b['score'].compareTo(a['score']));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final myRank = leaderboard.indexWhere((p) => p['name'] == 'You') + 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Leaderboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: leaderboard.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Your Stats Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: Colors.deepPurple[50],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          myRank.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: const Text(
                        "Your Performance",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Score: ${myScore ?? 0}   |   Rank: #$myRank",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.star, color: Colors.amber),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Top Global Players",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Leaderboard list
                  Expanded(
                    child: ListView.builder(
                      itemCount: leaderboard.length,
                      itemBuilder: (context, index) {
                        final entry = leaderboard[index];
                        final isYou = entry['name'] == 'You';
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isYou
                                ? Colors.deepPurple[100]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isYou
                                  ? Colors.deepPurple
                                  : Colors.deepPurple[200],
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              entry['name'],
                              style: TextStyle(
                                fontWeight: isYou
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text("Score: ${entry['score']}"),
                            trailing: Text(
                              entry['time'],
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
