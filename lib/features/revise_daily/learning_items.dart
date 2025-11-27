//lib/features/learn_daily/learning_items.dart
import 'dart:math' as Math;

class LearningItems {
  static List<String> multiplicationTable(int n, {int upto = 100}) {
    return List.generate(upto, (i) => '${n} × ${i + 1} = ${n * (i + 1)}');
  }

  static List<String> tablesUpTo({int upto = 12, int maxMultiplier = 100}) {
    final List<String> out = [];
    for (var i = 1; i <= upto; i++) {
      out.addAll(multiplicationTable(i, upto: maxMultiplier));
      out.add('');
    }
    return out;
  }

  static List<String> squares({int from = 1, int to = 100}) {
    return List.generate(to - from + 1, (i) {
      final n = i + from;
      return '$n² = ${n * n}';
    });
  }

  static List<String> cubes({int from = 1, int to = 100}) {
    return List.generate(to - from + 1, (i) {
      final n = i + from;
      return '$n³ = ${n * n * n}';
    });
  }

  static List<String> squareRoots({int from = 1, int to = 100}) {
    return List.generate(to - from + 1, (i) {
      final n = i + from;
      return '√$n ≈ ${(_formatDouble(Math.sqrt(n)))}';
    });
  }

  static List<String> cubeRoots({int from = 1, int to = 100}) {
    return List.generate(to - from + 1, (i) {
      final n = i + from;
      return '∛$n ≈ ${(_formatDouble(Math.pow(n, 1 / 3)))}';
    });
  }

  static List<String> percentageExamples({int from = 2, int to = 20}) {
    final List<String> out = [];

    for (int d = from; d <= to; d++) {
      final double percent = (1 / d) * 100;

      final String mixed = _percentToMixedFraction(percent);
      final String decimalPercent = _formatPercent(percent);

      out.add("1/$d → $mixed% → $decimalPercent%");
    }

    return out;
  }

  /// Convert float percent to mixed fraction:
  /// 16.66 → 16 2/3
  static String _percentToMixedFraction(double percent) {
    int whole = percent.floor();
    double fractional = percent - whole;

    if (fractional == 0) return whole.toString(); // e.g. "25"

    // Convert fractional part to nearest a/b
    const int maxDen = 20;
    int bestA = 0, bestB = 1;
    double bestError = 999;

    for (int b = 1; b <= maxDen; b++) {
      int a = (fractional * b).round();
      double error = (fractional - a / b).abs();
      if (error < bestError) {
        bestError = error;
        bestA = a;
        bestB = b;
      }
    }

    // reduce fraction
    int g = _gcd(bestA, bestB);
    bestA ~/= g;
    bestB ~/= g;

    if (bestA == 0) return whole.toString();

    return "$whole ${bestA}/${bestB}";
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      int t = a % b;
      a = b;
      b = t;
    }
    return a.abs();
  }

  static String _formatPercent(double value) {
    String s = value.toStringAsFixed(2);
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return s;
  }
}

String _formatDouble(num v) {
  if (v == v.roundToDouble()) return v.toString();
  return v.toStringAsFixed(3).replaceAll(RegExp(r"\.0+\$"), '');
}
