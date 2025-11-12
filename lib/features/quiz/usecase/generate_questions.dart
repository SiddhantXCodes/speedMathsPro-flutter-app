import 'dart:math';

class Question {
  final String expression;
  final String correctAnswer;

  Question({required this.expression, required this.correctAnswer});
}

class QuestionGenerator {
  static final _rnd = Random();

  /// Central entry point: generates question list for any topic
  static List<Question> generate(String topic, int min, int max, int count) {
    topic = topic.toLowerCase();
    switch (topic) {
      case 'addition':
        return _basic(op: '+', min: min, max: max, count: count);
      case 'subtraction':
        return _basic(op: '-', min: min, max: max, count: count);
      case 'multiplication':
        return _basic(op: '×', min: min, max: max, count: count);
      case 'division':
        return _basic(op: '÷', min: min, max: max, count: count);
      case 'percentage':
        return _percentage(min, max, count);
      case 'average':
        return _average(min, max, count);
      case 'square':
        return _square(min, max, count);
      case 'cube':
        return _cube(min, max, count);
      case 'square root':
        return _squareRoot(min, max, count);
      case 'cube root':
        return _cubeRoot(min, max, count);
      case 'trigonometry':
        return _trigonometry(count);
      case 'tables':
        return _tables(min, max, count);
      case 'data interpretation':
        return _dataInterpretation(count);
      case 'mixed questions':
        return _mixed(min, max, count);
      default:
        return _basic(op: '+', min: min, max: max, count: count);
    }
  }

  // 🔹 Basic arithmetic operations (improved for balanced variety)
  static List<Question> _basic({
    required String op,
    required int min,
    required int max,
    required int count,
  }) {
    return List.generate(count, (_) {
      int a, b;
      num result;

      switch (op) {
        case '+':
          // ✅ Normal random numbers (addition is fine)
          a = _rnd.nextInt(max - min + 1) + min;
          b = _rnd.nextInt(max - min + 1) + min;
          result = a + b;
          break;

        case '-':
          // ✅ Ensure no negative answers
          a = _rnd.nextInt(max - min + 1) + min;
          b = _rnd.nextInt(max - min + 1) + min;
          if (b > a) {
            final temp = a;
            a = b;
            b = temp;
          }
          result = a - b;
          break;

        case '×':
          // ✅ Make multiplicands less "close" — larger spread
          // Pick one small, one large value for better mix
          a = _rnd.nextInt((max - min) ~/ 2) + min; // smaller range
          b = _rnd.nextInt(max - min + 1) + (max ~/ 2); // larger number
          result = a * b;
          break;

        case '÷':
          // ✅ Ensure integer division with whole number result
          b = _rnd.nextInt((max - min) ~/ 2) + 2; // avoid 0 and 1
          result = _rnd.nextInt((max - min) ~/ 2) + 2;
          a = b * result.toInt(); // make a divisible by b
          break;

        default:
          // fallback (shouldn't occur)
          a = _rnd.nextInt(max - min + 1) + min;
          b = _rnd.nextInt(max - min + 1) + min;
          result = 0;
      }

      return Question(expression: '$a $op $b = ?', correctAnswer: '$result');
    });
  }

  // 🔹 Percentage Questions
  static List<Question> _percentage(int min, int max, int count) {
    return List.generate(count, (_) {
      final base = _rnd.nextInt(max - min + 1) + min;
      final percent = _rnd.nextInt(90) + 5;
      final result = (base * percent / 100).toStringAsFixed(2);
      return Question(
        expression: '$percent% of $base = ?',
        correctAnswer: result,
      );
    });
  }

  // 🔹 Average
  static List<Question> _average(int min, int max, int count) {
    return List.generate(count, (_) {
      final nums = List.generate(3, (_) => _rnd.nextInt(max - min + 1) + min);
      final avg = (nums.reduce((a, b) => a + b) / nums.length).toStringAsFixed(
        2,
      );
      return Question(
        expression: 'Average of ${nums.join(", ")} = ?',
        correctAnswer: avg,
      );
    });
  }

  // 🔹 Square
  static List<Question> _square(int min, int max, int count) {
    return List.generate(count, (_) {
      final n = _rnd.nextInt(max - min + 1) + min;
      return Question(expression: '$n² = ?', correctAnswer: '${n * n}');
    });
  }

  // 🔹 Cube
  static List<Question> _cube(int min, int max, int count) {
    return List.generate(count, (_) {
      final n = _rnd.nextInt(max - min + 1) + min;
      return Question(expression: '$n³ = ?', correctAnswer: '${n * n * n}');
    });
  }

  // 🔹 Square Root
  static List<Question> _squareRoot(int min, int max, int count) {
    return List.generate(count, (_) {
      final n = (_rnd.nextInt((max - min) ~/ 2) + min);
      final sq = n * n;
      return Question(expression: '√$sq = ?', correctAnswer: '$n');
    });
  }

  // 🔹 Cube Root
  static List<Question> _cubeRoot(int min, int max, int count) {
    return List.generate(count, (_) {
      final n = _rnd.nextInt((max - min) ~/ 2) + min;
      final cube = n * n * n;
      return Question(expression: '∛$cube = ?', correctAnswer: '$n');
    });
  }

  // 🔹 Tables (multiplication tables)
  static List<Question> _tables(int min, int max, int count) {
    final base = _rnd.nextInt(max - min + 1) + min;
    return List.generate(count, (i) {
      final b = i + 1;
      return Question(
        expression: '$base × $b = ?',
        correctAnswer: '${base * b}',
      );
    });
  }

  // 🔹 Trigonometry (basic degree-based)
  static List<Question> _trigonometry(int count) {
    final trigFuncs = ['sin', 'cos', 'tan'];
    final commonAngles = [0, 30, 45, 60, 90];
    final values = {
      'sin': ['0', '0.5', '0.707', '0.866', '1'],
      'cos': ['1', '0.866', '0.707', '0.5', '0'],
      'tan': ['0', '0.577', '1', '1.732', '∞'],
    };

    return List.generate(count, (_) {
      final f = trigFuncs[_rnd.nextInt(trigFuncs.length)];
      final idx = _rnd.nextInt(commonAngles.length);
      return Question(
        expression: '$f(${commonAngles[idx]}°) = ?',
        correctAnswer: values[f]![idx],
      );
    });
  }

  // 🔹 Data Interpretation (simple percent change)
  static List<Question> _dataInterpretation(int count) {
    return List.generate(count, (_) {
      final prev = _rnd.nextInt(900) + 100;
      final curr = _rnd.nextInt(900) + 100;
      final change = (((curr - prev) / prev) * 100).toStringAsFixed(1);
      return Question(
        expression: 'From $prev to $curr, change (%) = ?',
        correctAnswer: '$change%',
      );
    });
  }

  // 🔹 Mixed Question (random from all)
  static List<Question> _mixed(int min, int max, int count) {
    const allTopics = [
      'addition',
      'subtraction',
      'multiplication',
      'division',
      'square',
      'cube',
      'percentage',
      'average',
      'simplification',
    ];
    return List.generate(count, (_) {
      final t = allTopics[_rnd.nextInt(allTopics.length)];
      return generate(t, min, max, 1).first;
    });
  }
}
