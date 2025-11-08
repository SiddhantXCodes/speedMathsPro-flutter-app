import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/question_generator.dart';
import '../providers/performance_provider.dart';
import '../providers/practice_log_provider.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';

class DailyRankedQuizScreen extends StatefulWidget {
  const DailyRankedQuizScreen({super.key});

  @override
  State<DailyRankedQuizScreen> createState() => _DailyRankedQuizScreenState();
}

class _DailyRankedQuizScreenState extends State<DailyRankedQuizScreen> {
  late List<Question> questions;
  int currentIndex = 0;
  String typedAnswer = '';
  int score = 0;
  int correct = 0;
  int incorrect = 0;
  late Timer _timer;
  int remainingSeconds = 420; // 7 minutes
  bool quizEnded = false;
  bool _loading = true;

  final Map<int, String> userAnswers = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _generateQuestions();
      _startTimer();
    }
    _loading = false;
  }

  @override
  void dispose() {
    if (!_loading && !quizEnded) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _generateQuestions() {
    const topics = [
      'Addition',
      'Subtraction',
      'Multiplication',
      'Division',
      'Percentage',
      'Average',
      'Square',
      'Cube',
      'Square Root',
      'Cube Root',
      'Trigonometry',
      'Tables',
      'Data Interpretation',
      'Mixed Questions',
    ];

    final rnd = Random();
    questions = [];
    for (int i = 0; i < 20; i++) {
      final topic = topics[rnd.nextInt(topics.length)];
      final q = QuestionGenerator.generate(topic, 5, 50, 1).first;
      questions.add(q);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds <= 0) {
        _finishQuiz();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  void _onKeyTap(String val) {
    if (quizEnded) return;
    setState(() {
      if (val == 'BACK') {
        if (typedAnswer.isNotEmpty) {
          typedAnswer = typedAnswer.substring(0, typedAnswer.length - 1);
        }
      } else if (val == 'SUBMIT') {
        _submitAnswer();
      } else {
        typedAnswer += val;
      }
    });
  }

  bool _isCorrect(Question q, String ans) {
    final expected = q.correctAnswer.trim();
    if (ans.trim() == expected) return true;
    final a = double.tryParse(ans);
    final b = double.tryParse(expected);
    if (a != null && b != null) {
      return (a - b).abs() < 1e-6;
    }
    return false;
  }

  void _submitAnswer() {
    final curr = questions[currentIndex];
    final given = typedAnswer.trim();
    if (given.isEmpty) return;

    userAnswers[currentIndex] = given;
    final isRight = _isCorrect(curr, given);
    setState(() {
      if (isRight) {
        correct++;
        score += 4;
      } else {
        incorrect++;
        score -= 1;
      }
      typedAnswer = '';
      if (currentIndex + 1 >= questions.length) {
        _finishQuiz();
      } else {
        currentIndex++;
      }
    });
  }

  void _finishQuiz() async {
    if (quizEnded) return;
    _timer.cancel();
    setState(() => quizEnded = true);

    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setInt('daily_score_$todayKey', score);
    await prefs.setInt('daily_correct_$todayKey', correct);
    await prefs.setInt('daily_incorrect_$todayKey', incorrect);

    final performance = Provider.of<PerformanceProvider>(
      context,
      listen: false,
    );
    await performance.addTodayScore(score);

    try {
      final logProvider = Provider.of<PracticeLogProvider>(
        context,
        listen: false,
      );
      await logProvider.addSession(
        topic: 'Daily Ranked Quiz',
        score: correct,
        total: questions.length,
        timeSpentSeconds: 420 - remainingSeconds,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to log daily ranked session: $e');
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DailyRankedResultScreen(
            total: questions.length,
            score: score,
            correct: correct,
            incorrect: incorrect,
            answers: userAnswers,
            questions: questions,
            timeTaken: 420 - remainingSeconds,
          ),
        ),
      );
    }
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final cardColor = AppTheme.adaptiveCard(context);

    // 🔒 If not logged in → redirect prompt
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Daily Ranked Quiz"),
          backgroundColor: theme.appBarTheme.backgroundColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 58, color: accent),
                  const SizedBox(height: 12),
                  Text(
                    "Sign in to compete in Daily Ranked Quizzes\nand earn your global rank!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login_rounded, color: Colors.white),
                    label: const Text(
                      "Login to Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 🧮 Logged-in: show quiz
    if (_loading || questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[currentIndex];
    final time = _formatTime(remainingSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Ranked Quiz"),
        centerTitle: true,
        backgroundColor: accent,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: quizEnded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Score & Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Score: $score",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "⏱ $time",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question
                    Expanded(
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: textColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: q.expression.replaceAll('= ?', '= '),
                              ),
                              TextSpan(
                                text: typedAnswer.isEmpty ? '?' : typedAnswer,
                                style: TextStyle(
                                  color: typedAnswer.isEmpty
                                      ? textColor.withOpacity(0.5)
                                      : accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildKeyboard(accent, textColor),

                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      color: accent,
                      backgroundColor: theme.dividerColor.withOpacity(0.2),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${currentIndex + 1}/${questions.length}",
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildKeyboard(Color accent, Color textColor) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'BACK'],
      ['SUBMIT'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: row.length == 1
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              final isBack = key == 'BACK';
              final isSubmit = key == 'SUBMIT';
              return Expanded(
                flex: row.length == 1 ? 3 : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () => _onKeyTap(key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSubmit
                          ? accent
                          : (isBack
                                ? Colors.grey.withOpacity(0.25)
                                : accent.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isBack
                        ? const Icon(Icons.backspace_outlined)
                        : Text(
                            key,
                            style: TextStyle(
                              color: isSubmit ? Colors.white : textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class DailyRankedResultScreen extends StatelessWidget {
  final int total;
  final int score;
  final int correct;
  final int incorrect;
  final Map<int, String> answers;
  final List<Question> questions;
  final int timeTaken;

  const DailyRankedResultScreen({
    super.key,
    required this.total,
    required this.score,
    required this.correct,
    required this.incorrect,
    required this.answers,
    required this.questions,
    required this.timeTaken,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.adaptiveAccent(context);
    final textColor = AppTheme.adaptiveText(context);
    final mins = (timeTaken ~/ 60).toString().padLeft(2, '0');
    final secs = (timeTaken % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Quiz Result"),
        backgroundColor: accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Score: $score",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Correct: $correct | Incorrect: $incorrect",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time Taken: $mins:$secs",
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const Divider(height: 30),
                ],
              ),
            ),
            ...List.generate(questions.length, (i) {
              final q = questions[i];
              final user = answers[i];
              final right = q.correctAnswer.trim();
              final correctAns = user != null && user.trim() == right;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: correctAns
                      ? Colors.green.withOpacity(0.9)
                      : Colors.redAccent.withOpacity(0.9),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  q.expression.replaceAll('= ?', '= ${q.correctAnswer}'),
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  'Your answer: ${user ?? "-"}',
                  style: TextStyle(
                    color: correctAns ? Colors.green : Colors.redAccent,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
