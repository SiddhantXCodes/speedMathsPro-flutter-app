import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final int min;
  final int max;
  final int count;

  const QuizScreen({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.count,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

enum KeyboardLayout { normal123, reversed789 }

enum InputMode { keyboard, options }

class _QuizScreenState extends State<QuizScreen> {
  static const _kAutoSubmitKey = 'auto_submit';
  static const _kLayoutKey = 'keyboard_layout';
  static const _kInputModeKey = 'input_mode';

  bool autoSubmit = true;
  KeyboardLayout layout = KeyboardLayout.normal123;
  InputMode inputMode = InputMode.keyboard;

  List<_Question> questions = [];
  int currentIndex = 0;
  String typedAnswer = '';
  int correctCount = 0;
  int incorrectCount = 0;

  Timer? _ticker;
  final Stopwatch _stopwatch = Stopwatch();
  String _timerText = '00:00:000';

  bool showFeedbackCorrect = false;
  bool showFeedbackIncorrect = false;

  SharedPreferences? _prefs;

  // Centralized colors
  late Color primary;
  late Color bgColor;
  late Color cardColor;
  late Color textColor;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _generateQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      autoSubmit = _prefs?.getBool(_kAutoSubmitKey) ?? true;
      layout = KeyboardLayout.values[_prefs?.getInt(_kLayoutKey) ?? 0];
      inputMode = InputMode.values[_prefs?.getInt(_kInputModeKey) ?? 0];
    });
  }

  Future<void> _savePrefs() async {
    await _prefs?.setBool(_kAutoSubmitKey, autoSubmit);
    await _prefs?.setInt(_kLayoutKey, layout.index);
    await _prefs?.setInt(_kInputModeKey, inputMode.index);
  }

  void _startTimer() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      final ms = _stopwatch.elapsedMilliseconds;
      final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
      final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
      final millis = (ms % 1000).toString().padLeft(3, '0');
      if (mounted) {
        setState(() => _timerText = '$minutes:$seconds:$millis');
      }
    });
  }

  void _generateQuestions() {
    final rnd = Random();
    final ops = _opFromTitle(widget.title);
    questions = List.generate(widget.count, (i) {
      final a = widget.min + rnd.nextInt(max(1, widget.max - widget.min + 1));
      final b = widget.min + rnd.nextInt(max(1, widget.max - widget.min + 1));
      return _Question(a: a, b: b, op: ops[rnd.nextInt(ops.length)]);
    });
  }

  List<String> _opFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('add')) return ['+'];
    if (t.contains('sub')) return ['-'];
    if (t.contains('mul')) return ['×', '*'];
    if (t.contains('div')) return ['÷', '/'];
    return ['+', '-', '×', '÷'];
  }

  void _onKeyTap(String value) {
    setState(() {
      if (value == 'BACK') {
        if (typedAnswer.isNotEmpty) {
          typedAnswer = typedAnswer.substring(0, typedAnswer.length - 1);
        }
      } else {
        typedAnswer += value;
      }
    });
    _maybeAutoSubmit();
  }

  void _maybeAutoSubmit() {
    if (!autoSubmit) return;
    final curr = questions[currentIndex];
    if (typedAnswer == curr.answerString) {
      _submitCurrent();
    } else if (typedAnswer.length >= curr.answerString.length &&
        int.tryParse(typedAnswer) != null) {
      _submitCurrent();
    }
  }

  void _submitCurrent() {
    if (typedAnswer.trim().isEmpty) return;
    final curr = questions[currentIndex];
    final correct = curr.checkAnswer(typedAnswer);
    curr.userAnswer = typedAnswer;

    setState(() {
      if (correct) {
        correctCount++;
        showFeedbackCorrect = true;
      } else {
        incorrectCount++;
        showFeedbackIncorrect = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        showFeedbackCorrect = false;
        showFeedbackIncorrect = false;
      });
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentIndex + 1 >= questions.length) {
      _finishQuiz();
    } else {
      setState(() {
        currentIndex++;
        typedAnswer = '';
      });
    }
  }

  void _finishQuiz() {
    _stopwatch.stop();
    _ticker?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          title: widget.title,
          correct: correctCount,
          incorrect: incorrectCount,
          total: questions.length,
          time: _timerText,
          questions: questions,
        ),
      ),
    );
  }

  void _toggleAutoSubmit() {
    setState(() => autoSubmit = !autoSubmit);
    _savePrefs();
  }

  void _cycleLayout() {
    setState(() {
      layout = layout == KeyboardLayout.normal123
          ? KeyboardLayout.reversed789
          : KeyboardLayout.normal123;
    });
    _savePrefs();
  }

  void _toggleInputMode() {
    setState(() {
      inputMode = inputMode == InputMode.keyboard
          ? InputMode.options
          : InputMode.keyboard;
    });
    _savePrefs();
  }

  List<String> _buildOptionsForCurrent() {
    final q = questions[currentIndex];
    final correct = q.answerString;
    final rnd = Random();
    final opts = {correct};
    while (opts.length < 4) {
      final delta = (rnd.nextInt(10) + 1) * (rnd.nextBool() ? 1 : -1);
      opts.add((q.answerNumeric + delta).toString());
    }
    return opts.toList()..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    primary = isDark
        ? const Color.fromARGB(255, 30, 32, 32)
        : Colors.blueAccent;
    bgColor = isDark
        ? const Color.fromARGB(255, 14, 15, 17)!
        : Colors.grey[50]!;
    cardColor = isDark ? Colors.grey[850]! : Colors.white;
    textColor = isDark ? Colors.white : Colors.black87;

    final q = questions[currentIndex];
    final questionText = '${q.a} ${q.op} ${q.b} = ';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _toggleAutoSubmit,
            icon: Icon(
              autoSubmit ? Icons.flash_on : Icons.flash_off,
              color: autoSubmit ? Colors.yellowAccent : Colors.white,
            ),
            tooltip: "Toggle Auto Submit",
          ),
          IconButton(
            onPressed: _toggleInputMode,
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            tooltip: "Change keyboard layout",
          ),
          IconButton(
            onPressed: _cycleLayout,
            icon: Icon(
              inputMode == InputMode.keyboard ? Icons.keyboard : Icons.list,
              color: Colors.white,
            ),
            tooltip: "Toggle input mode",
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Status row
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iconStatus(Icons.check_circle, correctCount, Colors.green),
                  _iconStatus(Icons.cancel, incorrectCount, Colors.red),
                  _iconStatus(
                    Icons.timer,
                    null,
                    Colors.orange,
                    time: _timerText,
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / questions.length,
                    color: Colors.grey[800],
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${currentIndex + 1}/${questions.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Question area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ Question text stays fixed
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(text: questionText),
                        TextSpan(
                          text: typedAnswer.isEmpty ? '?' : typedAnswer,
                          style: TextStyle(
                            color: typedAnswer.isEmpty
                                ? primary
                                : Colors.greenAccent.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Feedback icon floats above (no layout shift)
                  if (showFeedbackCorrect || showFeedbackIncorrect)
                    Positioned(
                      top: 0,
                      child: Icon(
                        showFeedbackCorrect ? Icons.check_circle : Icons.cancel,
                        color: showFeedbackCorrect ? Colors.green : Colors.red,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ),

            // Keyboard / options
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: inputMode == InputMode.keyboard
                  ? _buildKeyboard(primary, isDark)
                  : _buildOptions(_buildOptionsForCurrent(), primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconStatus(IconData icon, int? val, Color color, {String? time}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          time ?? '$val',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboard(Color primary, bool isDark) {
    final normal = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', 'BACK'],
    ];
    final reversed = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['.', '0', 'BACK'],
    ];
    final grid = layout == KeyboardLayout.normal123 ? normal : reversed;
    return Column(
      children: [
        if (!autoSubmit)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: _submitCurrent,
              icon: const Icon(Icons.send, size: 16, color: Colors.white),
              label: const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        ...grid.map(
          (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: row.map((key) {
                final isBack = key == 'BACK';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBack
                            ? (isDark ? Colors.grey[300] : Colors.grey[200])
                            : primary.withOpacity(0.9),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _onKeyTap(isBack ? 'BACK' : key),
                      child: isBack
                          ? Icon(
                              Icons.backspace_outlined,
                              color: isDark ? Colors.black : Colors.black87,
                            )
                          : Text(
                              key,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(List<String> options, Color primary) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: options.map((opt) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() => typedAnswer = opt);
            _submitCurrent();
          },
          child: Text(
            opt,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Question model
class _Question {
  final int a;
  final int b;
  final String op;
  String? userAnswer;

  _Question({required this.a, required this.b, required this.op});

  int get answerNumeric {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
      case '*':
        return a * b;
      case '÷':
      case '/':
        if (b == 0) return 0;
        return (a / b).round();
      default:
        return a + b;
    }
  }

  String get answerString => answerNumeric.toString();

  bool checkAnswer(String ans) =>
      ans.trim() == answerString || int.tryParse(ans.trim()) == answerNumeric;
}

/// Result Screen
class QuizResultScreen extends StatelessWidget {
  final String title;
  final int correct;
  final int incorrect;
  final int total;
  final String time;
  final List<_Question> questions;

  const QuizResultScreen({
    super.key,
    required this.title,
    required this.correct,
    required this.incorrect,
    required this.total,
    required this.time,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final score = ((correct / total) * 100).round();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Score: $score%", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 6),
                  Text("Time: $time", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    "Correct: $correct  |  Incorrect: $incorrect",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            ...List.generate(questions.length, (i) {
              final q = questions[i];
              final isRight = q.userAnswer == q.answerString;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRight ? Colors.green : Colors.red,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('${q.a} ${q.op} ${q.b} = ${q.answerString}'),
                subtitle: Text(
                  'Your answer: ${q.userAnswer ?? "-"}',
                  style: TextStyle(
                    color: isRight ? Colors.green : Colors.redAccent,
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
