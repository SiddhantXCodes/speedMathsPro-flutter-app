class Level {
  /// Unique number for each level (1 → 50)
  final int levelNumber;

  /// Name or display title (e.g., “Level 1”)
  final String title;

  /// Total number of questions in this level
  final int totalQuestions;

  /// Minimum score needed to clear this level
  final int cutoffScore;

  /// Difficulty type: Easy / Medium / Hard / Expert / Insane
  final String difficulty;

  /// Time limit (in seconds)
  final int timeLimit;

  /// Whether this level is unlocked for the player
  bool isUnlocked;

  /// Whether the player has completed this level successfully
  bool isCompleted;

  /// Player’s best score so far in this level
  int bestScore;

  Level({
    required this.levelNumber,
    required this.title,
    required this.totalQuestions,
    required this.cutoffScore,
    required this.difficulty,
    required this.timeLimit,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestScore = 0,
  });

  /// Convert a Level object to a Map (for saving in local storage if needed)
  Map<String, dynamic> toMap() {
    return {
      'levelNumber': levelNumber,
      'title': title,
      'totalQuestions': totalQuestions,
      'cutoffScore': cutoffScore,
      'difficulty': difficulty,
      'timeLimit': timeLimit,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'bestScore': bestScore,
    };
  }

  /// Create Level object from Map
  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      levelNumber: map['levelNumber'],
      title: map['title'],
      totalQuestions: map['totalQuestions'],
      cutoffScore: map['cutoffScore'],
      difficulty: map['difficulty'],
      timeLimit: map['timeLimit'], // ✅ Added this line
      isUnlocked: map['isUnlocked'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      bestScore: map['bestScore'] ?? 0,
    );
  }
}
