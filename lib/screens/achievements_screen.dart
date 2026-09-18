import 'package:flutter/material.dart';

import '../models/player.dart';

class AchievementsScreen extends StatelessWidget {
  final Player player;

  const AchievementsScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      (
        '🌱',
        'Алғашқы қадам',
        'Первый шаг',
        'Бірінші сабақты аяқта',
        'Заверши первый урок',
        player.achievements.contains('first_lesson'),
      ),
      (
        '📚',
        'Бес сабақ',
        'Пять уроков',
        '5 сабақ аяқта',
        'Заверши 5 уроков',
        player.achievements.contains('five_lessons'),
      ),
      (
        '⭐',
        'Жаңа деңгей',
        'Новый уровень',
        '2 деңгейге жет',
        'Достигни 2 уровня',
        player.achievements.contains('level_2'),
      ),
      (
        '🔥',
        'Жалынды бастау',
        'Огненное начало',
        '7 күн қатарынан оқы',
        'Учись 7 дней подряд',
        player.streak >= 7,
      ),
      (
        '💎',
        'Табанды оқушы',
        'Упорный ученик',
        '10 сабақ аяқта',
        'Заверши 10 уроков',
        player.completedLessons.length >= 10,
      ),
      (
        '👑',
        'Хан',
        'Хан',
        '6 деңгейге жет',
        'Достигни 6 уровня',
        player.level >= 6,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Жетістіктер',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _DualText(kz: 'Менің жетістіктерім', ru: 'Мои достижения'),

          const SizedBox(height: 6),

          Text(
            '${player.achievements.length} / ${achievements.length}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),

          const SizedBox(height: 18),

          ...achievements.map(
            (a) => _AchievementCard(
              icon: a.$1,
              titleKz: a.$2,
              titleRu: a.$3,
              descriptionKz: a.$4,
              descriptionRu: a.$5,
              unlocked: a.$6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String icon;
  final String titleKz;
  final String titleRu;
  final String descriptionKz;
  final String descriptionRu;
  final bool unlocked;

  const _AchievementCard({
    required this.icon,
    required this.titleKz,
    required this.titleRu,
    required this.descriptionKz,
    required this.descriptionRu,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB),
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFFE6F4F1)
                  : const Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: unlocked
                ? Text(icon, style: const TextStyle(fontSize: 29))
                : const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKz,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: unlocked
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                ),

                Text(
                  titleRu,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  descriptionKz,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked
                        ? const Color(0xFF374151)
                        : const Color(0xFF9CA3AF),
                  ),
                ),

                Text(
                  descriptionRu,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          if (unlocked)
            const Icon(Icons.check_circle, color: Color(0xFF0F766E)),
        ],
      ),
    );
  }
}

class _DualText extends StatelessWidget {
  final String kz;
  final String ru;

  const _DualText({required this.kz, required this.ru});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kz,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        Text(
          ru,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}
