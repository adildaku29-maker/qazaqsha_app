enum QuestionType { choice, assemble, typing }

class Question {
  final String id;
  final QuestionType type;
  final String questionText;
  final String translation;
  final String? hint;
  final String correctAnswer;
  final List<String> options;

  const Question({
    required this.id,
    required this.type,
    required this.questionText,
    required this.translation,
    required this.correctAnswer,
    this.hint,
    this.options = const [],
  });
}

class Lesson {
  final int id;
  final String title;
  final String category;
  final String icon;
  final List<MapEntry<String, String>> vocabulary;
  final List<Question> questions;

  const Lesson({
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
  String gender;
  int skinColor;
  int xp;
  int streak;
  int hearts;
  String hintLanguage;
  int completedLessonsCount;
  List<int> completedLessons;

  Player({
    required this.nickname,
    required this.gender,
    required this.skinColor,
    this.xp = 0,
    this.streak = 1,
    this.hearts = 5,
    this.hintLanguage = 'ru',
    this.completedLessonsCount = 0,
    this.completedLessons = const [],
  });

  String get rankTitle {
    if (xp < 500) return 'Бала';
    if (xp < 1500) return 'Жігіт / Ару';
    if (xp < 3000) return 'Қайсар';
    return 'Батыр';
  }

  String get rankIcon {
    if (xp < 500) return '🌱';
    if (xp < 1500) return '🧑';
    if (xp < 3000) return '🛡️';
    return '⚔️';
  }

  String get avatarEmoji {
    if (gender == 'female') {
      if (xp < 500) return '👧';
      if (xp < 1500) return '👩';
      return '👸';
    }
    if (xp < 500) return '👦';
    if (xp < 1500) return '🧑';
    return '🧔‍♂️';
  }

  bool isCompleted(int lessonId) => completedLessons.contains(lessonId);

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'gender': gender,
        'skinColor': skinColor,
        'xp': xp,
        'streak': streak,
        'hearts': hearts,
        'hintLanguage': hintLanguage,
        'completedLessonsCount': completedLessonsCount,
        'completedLessons': completedLessons,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        nickname: (json['nickname'] as String?)?.trim().isNotEmpty == true
            ? json['nickname'] as String
            : 'Батыр',
        gender: json['gender'] as String? ?? 'male',
        skinColor: (json['skinColor'] as num?)?.toInt() ?? 0,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 1,
        hearts: (json['hearts'] as num?)?.toInt() ?? 5,
        hintLanguage: json['hintLanguage'] as String? ?? 'ru',
        completedLessonsCount:
            (json['completedLessonsCount'] as num?)?.toInt() ?? 0,
        completedLessons: ((json['completedLessons'] as List?) ?? const [])
            .whereType<num>()
            .map((e) => e.toInt())
            .toList(),
      );
}
