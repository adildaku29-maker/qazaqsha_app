import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/character.dart';

class HeroScreen extends StatelessWidget {
  final Player player;
  const HeroScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final ranks = [
      ('👶', 'Бала', 'Ребёнок'),
      ('🧒', 'Жас өрен', 'Юный'),
      ('🛡️', 'Сарбаз', 'Воин'),
      ('⚔️', 'Батыр', 'Герой'),
      ('🏹', 'Сардар', 'Сардар'),
      ('👑', 'Хан', 'Хан'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Кейіпкер')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _Dual('Сенің кейіпкерің', 'Твой герой'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8F5),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(children: [
                CharacterWidget(player: player, size: 155),
                Text(player.nickname, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 22),
            const Align(alignment: Alignment.centerLeft, child: _Dual('Дәреже', 'Ранг')),
            const SizedBox(height: 10),
            ...List.generate(ranks.length, (i) {
              final unlocked = player.level >= i + 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: unlocked ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB)),
                ),
                child: Row(children: [
                  Text(ranks[i].$1, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ranks[i].$2, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: unlocked ? const Color(0xFF111827) : const Color(0xFF9CA3AF))),
                    Text(ranks[i].$3, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ])),
                  Icon(unlocked ? Icons.check_circle : Icons.lock_outline, color: unlocked ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1)),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Dual extends StatelessWidget {
  final String a, b;
  const _Dual(this.a, this.b);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(a, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      Text(b, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ],
  );
}
