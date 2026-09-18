enum QuestionType { translate, assemble, speaking }

class DuoQuestion {
  final String id;
  final QuestionType type;
  final String questionText; // Фраза на казахском или русском
  final String? audioPath; // Путь к аудио/текст для озвучки
  final String correctAnswer; // Правильный ответ
  final List<String> options; // Варианты слов или ответов

  DuoQuestion({
    required this.id,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.options = const [],
    this.audioPath,
  });
}
