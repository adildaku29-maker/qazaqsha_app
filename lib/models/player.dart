class Player {
  final String nickname;
  final String hintLanguage;
  final String gender;
  final int skinColor;
  final int hairStyle;
  final int hairColor;
  final int clothes;
  final int glasses;
  final int level;
  final int xp;
  final int streak;
  final List<int> completedLessons;
  final List<String> achievements;

  const Player({
    required this.nickname,
    required this.hintLanguage,
    required this.gender,
    required this.skinColor,
    required this.hairStyle,
    required this.hairColor,
    required this.clothes,
    required this.glasses,
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.completedLessons = const [],
    this.achievements = const [],
  });

  Player copyWith({
    String? nickname,
    String? hintLanguage,
    String? gender,
    int? skinColor,
    int? hairStyle,
    int? hairColor,
    int? clothes,
    int? glasses,
    int? level,
    int? xp,
    int? streak,
    List<int>? completedLessons,
    List<String>? achievements,
  }) {
    return Player(
      nickname: nickname ?? this.nickname,
      hintLanguage: hintLanguage ?? this.hintLanguage,
      gender: gender ?? this.gender,
      skinColor: skinColor ?? this.skinColor,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      clothes: clothes ?? this.clothes,
      glasses: glasses ?? this.glasses,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      completedLessons: completedLessons ?? this.completedLessons,
      achievements: achievements ?? this.achievements,
    );
  }
}
