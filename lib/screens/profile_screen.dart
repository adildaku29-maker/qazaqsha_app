import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/character.dart';

class ProfileScreen extends StatelessWidget {
  final Player player;
  const ProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEAF7F4), Color(0xFFF4F1FF)]),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(children: [
              CharacterWidget(player: player, size: 105),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(player.nickname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                Text(rank(player.level), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                Text(rankRu(player.level), style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 8),
                Text('${player.xp} XP · ${player.completedLessons.length} уроков', style: const TextStyle(color: Color(0xFF6B7280))),
              ])),
            ]),
          ),
          const SizedBox(height: 25),
          const _Dual('Статистика', 'Статистика'),
          const SizedBox(height: 12),
          _item(Icons.local_fire_department_outlined, 'Серия', 'Серия', '${player.streak} дней'),
          _item(Icons.menu_book_outlined, 'Сабақтар', 'Уроки', '${player.completedLessons.length}'),
          _item(Icons.star_outline, 'Тәжірибе', 'Опыт', '${player.xp} XP'),
          _item(Icons.emoji_events_outlined, 'Жетістіктер', 'Достижения', '${player.achievements.length}'),
          const SizedBox(height: 22),
          const _Dual('Баптаулар', 'Настройки'),
          const SizedBox(height: 12),
          _item(Icons.language, 'Көмек тілі', 'Язык подсказок', player.hintLanguage),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String kz, String ru, String value) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF0F766E)),
      title: Text(kz, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(ru, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  String rank(int l) => ['Бала', 'Жас өрен', 'Сарбаз', 'Батыр', 'Сардар', 'Хан'][((l - 1).clamp(0, 5))];
  String rankRu(int l) => ['Ребёнок', 'Юный', 'Воин', 'Герой', 'Сардар', 'Хан'][((l - 1).clamp(0, 5))];
}

class _Dual extends StatelessWidget {
  final String a, b;
  const _Dual(this.a, this.b);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(a, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      Text(b, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ],
  );
}
