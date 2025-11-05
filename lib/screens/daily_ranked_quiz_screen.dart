import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/question_generator.dart';
import 'package:provider/provider.dart';
import '../providers/performance_provider.dart';
import '../providers/practice_log_provider.dart';

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

  final Map<int, String> userAnswers = {};

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
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

    // Balanced random pick across topics
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

    // ✅ Update performance provider (your leaderboard logic)
    final performance = Provider.of<PerformanceProvider>(
      context,
      listen: false,
    );
    await performance.addTodayScore(score);

    // ✅ NEW: Log to PracticeLogProvider (for heatmap + summary)
    try {
      final logProvider = Provider.of<PracticeLogProvider>(
        context,
        listen: false,
      );
      await logProvider.addSession(
        topic: 'Daily Ranked Quiz',
        score: correct, // correct answers
        total: questions.length, // total questions
        timeSpentSeconds: 420 - remainingSeconds, // since you use a 7-min timer
      );
    } catch (e) {
      debugPrint('⚠️ Failed to log daily ranked session: $e');
    }

    // ✅ Navigate to result screen
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
    final q = questions[currentIndex];
    final time = _formatTime(remainingSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Ranked Quiz"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: quizEnded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Score + Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Score: $score",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "⏱ $time",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question area
                    Expanded(
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
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
                                      ? Colors.grey
                                      : Colors.greenAccent.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Keyboard
                    _buildKeyboard(),

                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / questions.length,
                      color: Colors.deepPurple,
                      backgroundColor: Colors.grey[300],
                      minHeight: 6,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${currentIndex + 1}/${questions.length}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
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
                          ? Colors.deepPurple
                          : (isBack
                                ? Colors.grey[300]
                                : Colors.deepPurple[200]),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isBack
                        ? const Icon(
                            Icons.backspace_outlined,
                            color: Colors.black,
                          )
                        : Text(
                            key,
                            style: TextStyle(
                              color: isSubmit ? Colors.white : Colors.black,
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
    final mins = (timeTaken ~/ 60).toString().padLeft(2, '0');
    final secs = (timeTaken % 60).toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Quiz Result"),
        backgroundColor: Colors.deepPurple,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Correct: $correct | Incorrect: $incorrect",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Time Taken: $mins:$secs",
                    style: const TextStyle(fontSize: 16),
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
                  backgroundColor: correctAns ? Colors.green : Colors.red,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  q.expression.replaceAll('= ?', '= ${q.correctAnswer}'),
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
