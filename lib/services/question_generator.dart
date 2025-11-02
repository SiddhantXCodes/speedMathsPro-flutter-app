import 'dart:math';
import '../models/question_model.dart';

class QuestionGenerator {
  final Random _rand;

  QuestionGenerator([int? seed])
    : _rand = seed == null ? Random() : Random(seed);

  List<QuestionModel> generateLevelQuestions(int level, {int count = 5}) {
    final List<QuestionModel> list = [];
    for (int i = 0; i < count; i++) {
      list.add(_generateQuestion(level));
    }
    return list;
  }

  QuestionModel _generateQuestion(int level) {
    if (level <= 5) return _basic(level);
    if (level <= 10) return _bodmas(level);
    if (level <= 15) return _percentage(level);
    if (level <= 20) return _ratio(level);
    if (level <= 25) return _mixed(level);
    return _pattern(level);
  }

  int _randIn(int a, int b) => a + _rand.nextInt((b - a) + 1);

  // Helper to create random 4-option list
  List<String> _generateOptions(num correct) {
    final set = <int>{correct.toInt()};
    while (set.length < 4) {
      set.add(correct.toInt() + _randIn(-10, 10));
    }
    final list = set.map((e) => e.toString()).toList()..shuffle();
    return list;
  }

  // --- Question types ---

  QuestionModel _basic(int level) {
    final max = level <= 3 ? 9 : 99;
    final a = _randIn(1, max);
    final b = _randIn(1, max);
    final op = _rand.nextBool() ? '+' : '-';
    final correct = op == '+' ? (a + b) : (a - b);
    final q = '$a $op $b = ?';
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toString());
    return QuestionModel(
      question: q,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  QuestionModel _bodmas(int level) {
    final a = _randIn(2, 50);
    final b = _randIn(2, 30);
    final c = _randIn(1, 20);
    final text = '($a + $b) × $c = ?';
    final correct = (a + b) * c;
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toString());
    return QuestionModel(
      question: text,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  QuestionModel _percentage(int level) {
    final base = _randIn(50, 500);
    final pct = _randIn(1, 50);
    final text = '$pct% of $base = ?';
    final correct = (pct / 100 * base);
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toInt().toString());
    return QuestionModel(
      question: text,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  QuestionModel _ratio(int level) {
    final total = _randIn(100, 1000);
    final pct = _randIn(10, 90);
    final text = 'If total is $total and A gets $pct%, then A gets = ?';
    final correct = (total * pct / 100);
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toInt().toString());
    return QuestionModel(
      question: text,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  QuestionModel _mixed(int level) {
    final a = _randIn(10, 99);
    final b = _randIn(1, 10);
    final text = '$a × $b + 10 = ?';
    final correct = a * b + 10;
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toString());
    return QuestionModel(
      question: text,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }

  QuestionModel _pattern(int level) {
    final start = _randIn(2, 20);
    final diff = _randIn(2, 10);
    final series = [start, start + diff, start + 2 * diff, start + 3 * diff];
    final text = 'Find the next number: ${series.join(', ')}, ?';
    final correct = start + 4 * diff;
    final options = _generateOptions(correct);
    final correctIndex = options.indexOf(correct.toString());
    return QuestionModel(
      question: text,
      options: options,
      correctOptionIndex: correctIndex,
    );
  }
}
