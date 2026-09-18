class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

final List<Achievement> initialAchievements = [
  Achievement(
    id: 'first_lesson',
    title: 'Алғашқы қадам',
    description: 'Пройдите 1-й урок',
    icon: '🐣',
  ),
  Achievement(
    id: 'mic_master',
    title: 'Соловей Степи',
    description: 'Успешно выполните 5 разговорных заданий',
    icon: '🎙️',
  ),
  Achievement(
    id: 'streak_3',
    title: 'Тұрақтылық',
    description: 'Учитесь 3 дня подряд',
    icon: '🔥',
  ),
  Achievement(
    id: 'xp_500',
    title: 'Батыр',
    description: 'Наберите 500 XP',
    icon: '🛡️',
  ),
];
