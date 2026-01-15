import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'quiz_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../../providers/local_user_provider.dart';
import '../../../services/hive_service.dart';

class DailyRankedQuizEntry extends StatefulWidget {
  const DailyRankedQuizEntry({super.key});

  @override
  State<DailyRankedQuizEntry> createState() => _DailyRankedQuizEntryState();
}

class _DailyRankedQuizEntryState extends State<DailyRankedQuizEntry> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    // 🔒 One attempt per day (offline enforced)
    final alreadyPlayed = await HiveService.hasRankedAttemptToday();

    if (!mounted) return;

    if (alreadyPlayed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    final user = context.read<LocalUserProvider>();

    // 🧠 SAFETY: username must exist
    if (!user.hasUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set your username first"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          title: "Daily Ranked Quiz",
          min: 1,
          max: 50,
          count: 10,
          mode: QuizMode.dailyRanked,
          timeLimitSeconds: 150,

          // 👇 Identity (offline-safe)
          rankedUsername: user.username!,
          rankedDeviceId: user.deviceId!,

          // ✅ FIXED: async + return
          onFinish: (_) async {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
            );
            return;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loader screen while checks happen
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
