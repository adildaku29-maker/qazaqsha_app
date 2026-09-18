import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class LessonResultScreen extends StatefulWidget {
  final int correct;
  final int total;
  final int lessonId;

  const LessonResultScreen({
    super.key,
    required this.correct,
    required this.total,
    this.lessonId = 1,
  });

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  Player? updatedPlayer;
  bool leveledUp = false;

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    final old = await StorageService.loadPlayer();
    if (old == null) return;
    final xp = widget.correct * 10;
    final updated = await StorageService.addLessonProgress(old, widget.lessonId, xp);
    if (mounted) {
      setState(() {
        updatedPlayer = updated;
        leveledUp = updated.level > old.level;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp = widget.correct * 10;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Text(leveledUp ? '🎊' : '🎉', style: const TextStyle(fontSize: 78)),
            const SizedBox(height: 18),
            const _Dual('Сабақ аяқталды!', 'Урок завершён!'),
            const SizedBox(height: 10),
            Text('${widget.correct} / ${widget.total}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const Text('Дұрыс жауаптар / Правильных ответов', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: const Color(0xFFE6F4F1), borderRadius: BorderRadius.circular(25)),
              child: Column(children: [
                const Text('+ XP', style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.w800)),
                Text('$xp', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Color(0xFF0F766E))),
              ]),
            ),
            if (leveledUp && updatedPlayer != null) ...[
              const SizedBox(height: 18),
              const _Dual('Жаңа деңгей!', 'Новый уровень!'),
              Text('${updatedPlayer!.level}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 58,
              child: ElevatedButton(
                onPressed: updatedPlayer == null ? null : () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen(player: updatedPlayer!)),
                    (_) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Жалғастыру', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('Продолжить', style: TextStyle(fontSize: 10)),
                ]),
              ),
            ),
          ]),
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
    children: [
      Text(a, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      Text(b, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ],
  );
}
