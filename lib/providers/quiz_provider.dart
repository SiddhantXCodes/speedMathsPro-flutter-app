// lib/providers/quiz_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../models/level_model.dart';
import 'progress_provider.dart';

class QuizProvider extends ChangeNotifier {
  final ProgressProvider? progressProvider;

  QuizProvider({this.progressProvider});

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _totalQuestions = 0;
  int _coinsEarned = 0;
  bool _isCompleted = false;
  int _timeLeft = 60;

  Timer? _timer;
  Level? _currentLevel;

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get totalQuestions => _totalQuestions;
  int get coinsEarned => _coinsEarned;
  bool get isCompleted => _isCompleted;
  int get timeLeft => _timeLeft;
  QuestionModel get currentQuestion => _questions[_currentIndex];

  /// Start quiz for a particular level
  void startQuiz(Level level) {
    _currentLevel = level;
    _score = 0;
    _coinsEarned = 0;
    _isCompleted = false;
    _currentIndex = 0;
    _questions = _generateQuestions(level);
    _startTimer(level.timeLimit);
    notifyListeners();
  }

  /// 🔹 Generates random questions based on difficulty
  List<QuestionModel> _generateQuestions(Level level) {
    final random = Random();
    List<QuestionModel> list = [];

    for (int i = 0; i < level.totalQuestions; i++) {
      int a, b, correctAnswer;
      String questionText;
      List<String> options = [];

      switch (level.difficulty.toLowerCase()) {
        case 'easy':
          a = random.nextInt(20) + 1;
          b = random.nextInt(20) + 1;
          questionText = "$a + $b = ?";
          correctAnswer = a + b;
          break;
        case 'medium':
          a = random.nextInt(50) + 10;
          b = random.nextInt(50) + 10;
          questionText = "$a × $b = ?";
          correctAnswer = a * b;
          break;
        case 'hard':
          a = random.nextInt(100) + 20;
          b = random.nextInt(50) + 10;
          questionText = "$a ÷ $b = ?";
          correctAnswer = (a / b).round();
          break;
        case 'expert':
          a = random.nextInt(300) + 50;
          b = random.nextInt(200) + 20;
          int mult = random.nextInt(10) + 2;
          questionText = "($a - $b) × $mult = ?";
          correctAnswer = (a - b) * mult;
          break;
        case 'insane':
          a = random.nextInt(900) + 100;
          b = random.nextInt(900) + 100;
          int c = random.nextInt(50) + 10;
          questionText = "($a + $b) × $c = ?";
          correctAnswer = (a + b) * c;
          break;
        default:
          a = random.nextInt(10) + 1;
          b = random.nextInt(10) + 1;
          questionText = "$a + $b = ?";
          correctAnswer = a + b;
      }

      options.add(correctAnswer.toString());
      while (options.length < 4) {
        int wrong = correctAnswer + random.nextInt(20) - 10;
        if (wrong != correctAnswer && !options.contains(wrong.toString())) {
          options.add(wrong.toString());
        }
      }
      options.shuffle();

      list.add(
        QuestionModel(
          question: questionText,
          options: options,
          correctOptionIndex: options.indexOf(correctAnswer.toString()),
        ),
      );
    }

    return list;
  }

  /// ⏳ Timer logic
  void _startTimer(int seconds) {
    _timeLeft = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      if (_timeLeft <= 0) {
        completeQuiz();
      }
      notifyListeners();
    });
  }

  /// ✅ Called when user selects an answer
  void answerQuestion(int selectedIndex) {
    if (isCompleted) return;

    if (_questions[_currentIndex].correctOptionIndex == selectedIndex) {
      _score += 10;
      _coinsEarned += 5;
    }

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
    } else {
      completeQuiz();
    }

    notifyListeners();
  }

  /// 🏁 Complete quiz
  void completeQuiz() {
    _timer?.cancel();
    _isCompleted = true;

    // ✅ Take snapshot before anything resets
    _finalScore = _score;
    _finalTotalQuestions = _questions.length;
    _finalCoins = _coinsEarned;
    if (isPassed) {
      unlockNextLevel();
    }

    notifyListeners();
  }

  void setTotalQuestions(int count) {
    _totalQuestions = count;
    notifyListeners();
  }

  void updateScore(int value) {
    _score = value;
    notifyListeners();
  }

  // ✅ Final result getters
  int _finalScore = 0;
  int _finalTotalQuestions = 0;
  int _finalCoins = 0;

  int get finalScore => _finalScore;
  int get finalTotalQuestions => _finalTotalQuestions;
  int get finalCoins => _finalCoins;

  /// 🔁 Reset quiz state
  void reset() {
    _timer?.cancel();
    _questions = [];
    _score = 0;
    _coinsEarned = 0;
    _isCompleted = false;
    _currentIndex = 0;
    _timeLeft = 0;
    notifyListeners();
  }

  /// 🔓 Unlock next level if cutoff is cleared
  void unlockNextLevel() {
    if (progressProvider == null || _currentLevel == null) return;

    if (_score >= _currentLevel!.cutoffScore * 10) {
      progressProvider!.unlockNextLevel(
        _currentLevel!.levelNumber,
        _coinsEarned,
      );
    }
  }

  /// 🧮 Pass logic uses *final* values once quiz is done
  bool get isPassed {
    int totalPossible = _finalTotalQuestions * 10;
    return totalPossible > 0 && _finalScore >= totalPossible * 0.7;
  }

  void saveResult() {
    if (progressProvider == null || _currentLevel == null) return;

    if (isPassed) {
      progressProvider!.unlockNextLevel(
        _currentLevel!.levelNumber,
        _coinsEarned,
      );
    }
  }
}
