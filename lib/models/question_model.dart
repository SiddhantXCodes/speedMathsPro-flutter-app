class QuestionModel {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctOptionIndex;
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'],
      options: List<String>.from(map['options']),
      correctOptionIndex: map['correctOptionIndex'],
    );
  }
}
