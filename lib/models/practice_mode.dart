// lib/models/practice_mode.dart
import '../features/quiz/screens/practice_overview_screen.dart';

enum PracticeMode {
  dailyPractice,
  mixedPractice,
  addition,
  subtraction,
  multiplication,
  division,
  percentage,
  average,
  square,
  cube,
  squareRoot,
  cubeRoot,
  tables,
  dataInterpretation,
}

extension PracticeModeX on PracticeMode {
  static PracticeMode? fromTitle(String title) {
    switch (title.toLowerCase().trim()) {
      case "addition":
        return PracticeMode.addition;
      case "subtraction":
        return PracticeMode.subtraction;
      case "multiplication":
        return PracticeMode.multiplication;
      case "division":
        return PracticeMode.division;
      case "percentage":
        return PracticeMode.percentage;
      case "average":
        return PracticeMode.average;
      case "square":
        return PracticeMode.square;
      case "cube":
        return PracticeMode.cube;
      case "square root":
        return PracticeMode.squareRoot;
      case "cube root":
        return PracticeMode.cubeRoot;
      case "tables":
        return PracticeMode.tables;
      case "data interpretation":
        return PracticeMode.dataInterpretation;
      default:
        return null;
    }
  }
}
