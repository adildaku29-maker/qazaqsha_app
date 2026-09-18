import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/ornament_container.dart';

class ProfileScreen extends StatelessWidget {
  final Player player;

  const ProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    // Автоматическое определение звания на основе XP
    String getRank(int xp) {
      if (xp >= 1000) return 'Улы Батыр 👑';
      if (xp >= 500) return 'Батыр 🛡️';
      if (xp >= 200) return 'Жасулан 🗡️';
      return 'Талапкер 🌟';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: const Text('Жеке кабинет (Профиль)'),
        backgroundColor: const Color(0xFF00A896),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Карточка пользователя с орнаментом
            OrnamentContainer(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFE5A93C).withOpacity(0.2),
                    child: Text(
                      player.avatarEmoji ?? '🇰🇿',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    player.name.isNotEmpty ? player.name : 'Қолданушы',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5A93C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getRank(player.xp),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Статистика
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '⚡ XP Трек',
                    '${player.xp} XP',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '📚 Уроки',
                    '${player.completedLessonsCount}/10',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Раздел Ачивок / Достижений
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Жетістіктер (Достижения)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _buildAchievementTile(
              '🐣',
              'Алғашқы қадам',
              'Пройден 1-й урок',
              player.completedLessonsCount >= 1,
            ),
            _buildAchievementTile(
              '🛡️',
              'Настоящий Батыр',
              'Набрано более 500 XP',
              player.xp >= 500,
            ),
            _buildAchievementTile(
              '🎙️',
              'Соловей Степи',
              'Отличная разговорная речь',
              player.completedLessonsCount >= 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(
    String icon,
    String title,
    String desc,
    bool unlocked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? const Color(0xFFE5A93C) : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Text(
          icon,
          style: TextStyle(fontSize: 32, color: unlocked ? null : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(color: unlocked ? Colors.black87 : Colors.grey),
        ),
        trailing: Icon(
          unlocked ? Icons.check_circle : Icons.lock,
          color: unlocked ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
