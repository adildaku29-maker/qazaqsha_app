enum QuestionType { choice, speaking, assemble }

class Question {
  final String id;
  final QuestionType type;
  final String questionText;
  final String questionTranslation; // Подстрочный перевод вопроса
  final String? hintText; // Подсказка по сложным конструкциям
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.id,
    required this.type,
    required this.questionText,
    required this.questionTranslation,
    this.hintText,
    required this.correctAnswer,
    this.options = const [],
  });
}

class Lesson {
  final String id;
  final String title;
  final String category;
  final String icon;
  final Map<String, String>
  vocabulary; // Словарь для интро (100% покрытие вопросов)
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.vocabulary,
    required this.questions,
  });
}

class Player {
  String nickname;
  String gender; // 'male' или 'female'
  int skinColor; // Index 0..2
  int xp;
  int streak;
  int hearts;
  String hintLanguage; // 'ru' или 'en'
  int completedLessonsCount;

  Player({
    required this.nickname,
    required this.gender,
    required this.skinColor,
    this.xp = 0,
    this.streak = 1,
    this.hearts = 5,
    this.hintLanguage = 'ru',
    this.completedLessonsCount = 0,
  });

  // Получаем текущий титул персонажа по XP
  String get rankTitle {
    if (xp < 500) return 'Бала 👶';
    if (xp < 1500) return 'Жігіт / Ару 🧑';
    if (xp < 3000) return 'Еркек / Қайсар 🧔';
    return 'Батыр ⚔️';
  }

  // Получаем иконку-эмодзи персонажа
  String get avatarEmoji {
    if (gender == 'female') {
      if (xp < 500) return '👧';
      if (xp < 1500) return '👩';
      return '👸';
    } else {
      if (xp < 500) return '👦';
      if (xp < 1500) return '🧑';
      return '🧔‍♂️';
    }
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'gender': gender,
    'skinColor': skinColor,
    'xp': xp,
    'streak': streak,
    'hearts': hearts,
    'hintLanguage': hintLanguage,
    'completedLessonsCount': completedLessonsCount,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    nickname: json['nickname'] ?? 'Батыр',
    gender: json['gender'] ?? 'male',
    skinColor: json['skinColor'] ?? 0,
    xp: json['xp'] ?? 0,
    streak: json['streak'] ?? 1,
    hearts: json['hearts'] ?? 5,
    hintLanguage: json['hintLanguage'] ?? 'ru',
    completedLessonsCount: json['completedLessonsCount'] ?? 0,
  );
}
