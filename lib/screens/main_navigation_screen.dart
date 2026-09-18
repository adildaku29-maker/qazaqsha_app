import 'package:flutter/material.dart';
import '../data/lessons_data.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'duo_lesson_screen.dart';
import 'onboarding_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Player player;
  const MainNavigationScreen({super.key, required this.player});
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int index = 0;
  late Player player;
  @override void initState() { super.initState(); player = widget.player; }

  Future<void> refresh() async { final p = await StorageService.getPlayer(); if (p != null && mounted) setState(() => player = p); }

  @override Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: [_home(), _progress(), _profile()])),
    bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (i) => setState(() => index = i), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'), NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Герой'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль')]),
  );

  Widget _topStats() => Row(children: [Expanded(child: _stat('🔥', '${player.streak}', 'серия')), Expanded(child: _stat('⚡', '${player.xp}', 'XP')), Expanded(child: _stat('❤️', '${player.hearts}', 'сердца'))]);
  Widget _stat(String icon, String value, String label) => Column(children: [Text('$icon $value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))]);

  Widget _home() => RefreshIndicator(onRefresh: refresh, child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
    Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Сәлем, ${player.nickname}! 👋', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)), const Text('Бүгін қазақша сөйлейміз', style: TextStyle(color: Colors.grey))])), Text(player.avatarEmoji, style: const TextStyle(fontSize: 42))]),
    const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: _topStats())), const SizedBox(height: 18),
    const Text('Путь обучения', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('10 уроков • базовый уровень → культура', style: TextStyle(color: Colors.grey)), const SizedBox(height: 14),
    ...allLessons.map((l) => _lessonTile(l)),
  ]));

  Widget _lessonTile(Lesson l) {
    final done = player.isCompleted(l.id);
    final locked = l.id > 1 && !player.isCompleted(l.id - 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: done
              ? AppTheme.primary.withOpacity(.12)
              : Colors.grey.withOpacity(.1),
          child: Text(l.icon, style: const TextStyle(fontSize: 26)),
        ),
        title: Text(
          '${l.id}. ${l.title}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${l.category} • ${l.questions.length} заданий'),
        trailing: Icon(
          done
              ? Icons.check_circle
              : locked
                  ? Icons.lock_outline
                  : Icons.arrow_forward_ios,
          color: done ? AppTheme.primary : Colors.grey,
        ),
        onTap: locked
            ? null
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DuoLessonScreen(
                      player: player,
                      lesson: l,
                    ),
                  ),
                );
                await refresh();
              },
      ),
    );
  }

  Widget _progress() { final progress = player.completedLessonsCount / allLessons.length; return ListView(padding: const EdgeInsets.all(22), children: [Center(child: Text(player.avatarEmoji, style: const TextStyle(fontSize: 82))), Center(child: Text(player.rankIcon + '  ${player.rankTitle}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold))), const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [Text('${player.xp} XP', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 8), LinearProgressIndicator(value: progress.clamp(0, 1).toDouble(), minHeight: 10, borderRadius: BorderRadius.circular(10)), const SizedBox(height: 8), Text('${player.completedLessonsCount} из ${allLessons.length} уроков завершено')]))), const SizedBox(height: 20), const Text('Эволюция героя', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 10), _rank('🌱', 'Бала', '0–499 XP', player.xp < 500), _rank('🧑', 'Жігіт / Ару', '500–1499 XP', player.xp >= 500 && player.xp < 1500), _rank('🛡️', 'Қайсар', '1500–2999 XP', player.xp >= 1500 && player.xp < 3000), _rank('⚔️', 'Батыр', '3000+ XP', player.xp >= 3000)]); }
  Widget _rank(String icon, String title, String xp, bool active) => Card(color: active ? AppTheme.primary.withOpacity(.08) : null, child: ListTile(leading: Text(icon, style: const TextStyle(fontSize: 30)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(xp), trailing: active ? const Icon(Icons.check_circle, color: AppTheme.primary) : null));

  Widget _profile() => ListView(padding: const EdgeInsets.all(22), children: [Center(child: Text(player.avatarEmoji, style: const TextStyle(fontSize: 80))), Center(child: Text(player.nickname, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))), Center(child: Text('Подсказки: ${player.hintLanguage == 'ru' ? 'Русский' : 'English'}', style: const TextStyle(color: Colors.grey))), const SizedBox(height: 24), Card(child: Column(children: [ListTile(leading: const Icon(Icons.bolt), title: const Text('Опыт'), trailing: Text('${player.xp} XP')), ListTile(leading: const Icon(Icons.menu_book), title: const Text('Уроки'), trailing: Text('${player.completedLessonsCount}/10')), ListTile(leading: const Icon(Icons.local_fire_department), title: const Text('Серия'), trailing: Text('${player.streak} дней'))])), const SizedBox(height: 20), OutlinedButton.icon(onPressed: () async { await StorageService.clearPlayer(); if (!mounted) return; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()), (_) => false); }, icon: const Icon(Icons.restart_alt), label: const Text('Сбросить прогресс'))]);
}
