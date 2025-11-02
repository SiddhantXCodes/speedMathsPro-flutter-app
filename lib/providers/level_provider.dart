import 'package:flutter/foundation.dart';
import '../models/level_model.dart';
import '../providers/progress_provider.dart';

class LevelProvider extends ChangeNotifier {
  final List<Level> _levels = [];
  final ProgressProvider progressProvider;

  LevelProvider(this.progressProvider) {
    _generateLevels();
  }

  List<Level> get levels => _levels;

  /// 🔹 Generate all 50 levels with increasing cutoff & difficulty
  void _generateLevels() {
    int unlockedUpTo = progressProvider.highestLevel;

    _levels.clear();
    for (int i = 1; i <= 50; i++) {
      _levels.add(
        Level(
          levelNumber: i,
          title: 'Level $i',
          totalQuestions: 10,
          cutoffScore: _getCutoff(i),
          difficulty: _getDifficulty(i),
          timeLimit: _getTimeLimit(i),
          isUnlocked: i <= unlockedUpTo, // ✅ Unlock all up to saved progress
          isCompleted: i < unlockedUpTo, // ✅ Mark completed ones
        ),
      );
    }
  }

  /// 🔹 Defines the required cutoff based on difficulty band
  int _getCutoff(int level) {
    if (level <= 10) return 6; // Easy
    if (level <= 20) return 7; // Medium
    if (level <= 35) return 8; // Hard
    if (level <= 45) return 9; // Expert
    return 9; // Insane
  }

  /// 🔹 Defines difficulty text for display
  String _getDifficulty(int level) {
    if (level <= 10) return 'Easy';
    if (level <= 20) return 'Medium';
    if (level <= 35) return 'Hard';
    if (level <= 45) return 'Expert';
    return 'Insane';
  }

  /// 🔹 Set time limit based on difficulty
  int _getTimeLimit(int level) {
    if (level <= 10) return 60; // Easy → 60 seconds
    if (level <= 20) return 50; // Medium
    if (level <= 35) return 40; // Hard
    if (level <= 45) return 30; // Expert
    return 20; // Insane
  }

  /// 🔹 Called after user finishes a quiz
  void updateLevelProgress(int levelNumber, int score) {
    final currentLevel = _levels.firstWhere(
      (l) => l.levelNumber == levelNumber,
    );
    currentLevel.bestScore = score;

    // ✅ If cutoff is cleared, mark completed and unlock next level
    if (score >= currentLevel.cutoffScore) {
      currentLevel.isCompleted = true;

      if (levelNumber < _levels.length) {
        _levels[levelNumber].isUnlocked = true; // unlock next
      }
    }

    notifyListeners();
  }

  /// 🔹 Check if level is available to play
  bool canPlayLevel(int levelNumber) {
    final level = _levels.firstWhere((l) => l.levelNumber == levelNumber);
    return level.isUnlocked;
  }

  /// 🔹 Reset all levels (optional for debugging or reset button)
  void resetAllLevels() {
    for (var level in _levels) {
      level.isUnlocked = level.levelNumber == 1;
      level.isCompleted = false;
      level.bestScore = 0;
    }
    notifyListeners();
  }
}
