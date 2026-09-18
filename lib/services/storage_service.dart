import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class StorageService {
  static const _created = 'player_created';
  static const _nickname = 'nickname';
  static const _hintLanguage = 'hint_language';
  static const _gender = 'gender';
  static const _skin = 'skin';
  static const _hairStyle = 'hair_style';
  static const _hairColor = 'hair_color';
  static const _clothes = 'clothes';
  static const _glasses = 'glasses';
  static const _level = 'level';
  static const _xp = 'xp';
  static const _streak = 'streak';
  static const _lessons = 'completed_lessons';
  static const _achievements = 'achievements';

  static Future<bool> hasPlayer() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_created) ?? false;
  }

  static Future<Player?> loadPlayer() async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool(_created) ?? false)) return null;

    return Player(
      nickname: p.getString(_nickname) ?? 'Батыр',
      hintLanguage: p.getString(_hintLanguage) ?? 'Русский',
      gender: p.getString(_gender) ?? 'male',
      skinColor: p.getInt(_skin) ?? 1,
      hairStyle: p.getInt(_hairStyle) ?? 0,
      hairColor: p.getInt(_hairColor) ?? 0,
      clothes: p.getInt(_clothes) ?? 0,
      glasses: p.getInt(_glasses) ?? 0,
      level: p.getInt(_level) ?? 1,
      xp: p.getInt(_xp) ?? 0,
      streak: p.getInt(_streak) ?? 0,
      completedLessons: p.getStringList(_lessons)?.map(int.parse).toList() ?? [],
      achievements: p.getStringList(_achievements) ?? [],
    );
  }

  static Future<void> savePlayer(Player player) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_created, true);
    await p.setString(_nickname, player.nickname);
    await p.setString(_hintLanguage, player.hintLanguage);
    await p.setString(_gender, player.gender);
    await p.setInt(_skin, player.skinColor);
    await p.setInt(_hairStyle, player.hairStyle);
    await p.setInt(_hairColor, player.hairColor);
    await p.setInt(_clothes, player.clothes);
    await p.setInt(_glasses, player.glasses);
    await p.setInt(_level, player.level);
    await p.setInt(_xp, player.xp);
    await p.setInt(_streak, player.streak);
    await p.setStringList(_lessons, player.completedLessons.map((e) => e.toString()).toList());
    await p.setStringList(_achievements, player.achievements);
  }

  static Future<Player> addLessonProgress(Player player, int lessonId, int earnedXp) async {
    final lessons = [...player.completedLessons];
    if (!lessons.contains(lessonId)) lessons.add(lessonId);

    var xp = player.xp + earnedXp;
    var level = player.level;
    var leveledUp = false;

    while (xp >= 100) {
      xp -= 100;
      level++;
      leveledUp = true;
    }

    final achievements = [...player.achievements];
    if (lessons.length >= 1 && !achievements.contains('first_lesson')) {
      achievements.add('first_lesson');
    }
    if (lessons.length >= 5 && !achievements.contains('five_lessons')) {
      achievements.add('five_lessons');
    }
    if (level >= 2 && !achievements.contains('level_2')) {
      achievements.add('level_2');
    }

    final updated = player.copyWith(
      xp: xp,
      level: level,
      completedLessons: lessons,
      achievements: achievements,
    );
    await savePlayer(updated);
    return updated;
  }
}
