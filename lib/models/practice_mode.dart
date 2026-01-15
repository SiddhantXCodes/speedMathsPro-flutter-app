// lib/models/practice_mode.dart

/// Represents all supported practice and quiz modes.
/// This file must remain UI-agnostic (no widget imports).
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
  /// Convert enum → readable title
  String get title {
    switch (this) {
      case PracticeMode.dailyPractice:
        return "Daily Practice";
      case PracticeMode.mixedPractice:
        return "Mixed Practice";
      case PracticeMode.addition:
        return "Addition";
      case PracticeMode.subtraction:
        return "Subtraction";
      case PracticeMode.multiplication:
        return "Multiplication";
      case PracticeMode.division:
        return "Division";
      case PracticeMode.percentage:
        return "Percentage";
      case PracticeMode.average:
        return "Average";
      case PracticeMode.square:
        return "Square";
      case PracticeMode.cube:
        return "Cube";
      case PracticeMode.squareRoot:
        return "Square Root";
      case PracticeMode.cubeRoot:
        return "Cube Root";
      case PracticeMode.tables:
        return "Tables";
      case PracticeMode.dataInterpretation:
        return "Data Interpretation";
    }
  }

  /// Convert title/string → enum (safe & case-insensitive)
  static PracticeMode? fromTitle(String title) {
    final key = title.toLowerCase().trim();

    switch (key) {
      case "daily practice":
        return PracticeMode.dailyPractice;
      case "mixed practice":
        return PracticeMode.mixedPractice;
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

  /// Whether this mode is a custom / topic-based practice
  bool get isTopicMode {
    return this != PracticeMode.dailyPractice &&
        this != PracticeMode.mixedPractice;
  }
}
