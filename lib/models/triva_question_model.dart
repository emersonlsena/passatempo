class TrivaQuestionModel {
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> options;

  TrivaQuestionModel({
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory TrivaQuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> options = [...json['incorrectAnswers'], json['correctAnswer']];
    options.shuffle();
    return TrivaQuestionModel(
      category: json['category'],
      question: json['question']['text'],
      correctAnswer: json['correctAnswer'],
      options: options,
    );
  }
}
