import 'package:flutter/foundation.dart';
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

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int index = 0;
  late Player player;

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  Future<void> refresh() async {
    final p = await StorageService.getPlayer();
    if (p != null && mounted) {
      setState(() => player = p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: [
            _home(),
            _progress(),
            _profile(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Герой',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _home() {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _homeHeader()),
          SliverToBoxAdapter(child: _statsCard()),
          SliverToBoxAdapter(child: _mapTitle()),
          SliverToBoxAdapter(child: _lessonMap()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  Widget _homeHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сәлем, ${player.nickname}! 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Бүгін қазақша сөйлейміз',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              player.avatarEmoji,
              style: const TextStyle(fontSize: 34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.055),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _stat('🔥', '${player.streak}', 'серия')),
            _statDivider(),
            Expanded(child: _stat('⚡', '${player.xp}', 'XP')),
            _statDivider(),
            Expanded(child: _stat('❤️', '${player.hearts}', 'сердца')),
          ],
        ),
      ),
    );
  }

  Widget _stat(String icon, String value, String label) {
    return Column(
      children: [
        Text(
          '$icon  $value',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey.withOpacity(.14),
    );
  }

  Widget _mapTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Путь обучения',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Пройди путь от первых слов до культуры',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${player.completedLessonsCount}/${allLessons.length}',
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 1030,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFFEAF4EF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapBackgroundPainter(),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPathPainter(
                  completedLessons: player.completedLessons,
                ),
              ),
            ),
            for (int i = 0; i < allLessons.length; i++)
              _lessonNode(i, allLessons[i]),
          ],
        ),
      ),
    );
  }

  Widget _lessonNode(int index, Lesson lesson) {
    final completed = player.isCompleted(lesson.id);
    final unlocked =
        lesson.id == 1 || player.isCompleted(lesson.id - 1);
    final isCurrent = unlocked && !completed;

    // The path zig-zags naturally instead of stacking cards in a list.
    final x = index.isEven ? .25 : .72;
    final top = 38.0 + index * 96.0;

    return Positioned(
      top: top,
      left: MediaQuery.of(context).size.width * x - 58,
      child: GestureDetector(
        onTap: unlocked ? () => _openLesson(lesson) : null,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isCurrent ? 82 : 72,
              height: isCurrent ? 82 : 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? AppTheme.primary
                    : unlocked
                        ? Colors.white
                        : Colors.white.withOpacity(.72),
                border: Border.all(
                  color: isCurrent
                      ? AppTheme.gold
                      : completed
                          ? AppTheme.primary
                          : Colors.white,
                  width: isCurrent ? 4 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 34,
                      )
                    : Text(
                        unlocked ? lesson.icon : '🔒',
                        style: TextStyle(
                          fontSize: unlocked ? 31 : 25,
                          color: unlocked ? null : Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              constraints: const BoxConstraints(maxWidth: 135),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.94),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${lesson.id}. ${lesson.title}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    completed
                        ? 'Аяқталды'
                        : unlocked
                            ? 'Бастау'
                            : 'Құлыптаулы',
                    style: TextStyle(
                      fontSize: 10,
                      color: completed
                          ? AppTheme.primary
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(Lesson lesson) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuoLessonScreen(
          player: player,
          lesson: lesson,
        ),
      ),
    );
    await refresh();
  }

  Widget _progress() {
    final progress =
        player.completedLessonsCount / allLessons.length;

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Center(
          child: Text(
            player.avatarEmoji,
            style: const TextStyle(fontSize: 82),
          ),
        ),
        Center(
          child: Text(
            '${player.rankIcon}  ${player.rankTitle}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${player.xp} XP',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.clamp(0, 1).toDouble(),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Text(
                  '${player.completedLessonsCount} из ${allLessons.length} уроков завершено',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Эволюция героя',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _rank('🌱', 'Бала', '0–499 XP', player.xp < 500),
        _rank(
          '🧑',
          'Жігіт / Ару',
          '500–1499 XP',
          player.xp >= 500 && player.xp < 1500,
        ),
        _rank(
          '🛡️',
          'Қайсар',
          '1500–2999 XP',
          player.xp >= 1500 && player.xp < 3000,
        ),
        _rank('⚔️', 'Батыр', '3000+ XP', player.xp >= 3000),
      ],
    );
  }

  Widget _rank(String icon, String title, String xp, bool active) {
    return Card(
      color: active ? AppTheme.primary.withOpacity(.08) : null,
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(xp),
        trailing: active
            ? const Icon(
                Icons.check_circle,
                color: AppTheme.primary,
              )
            : null,
      ),
    );
  }

  Widget _profile() {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Center(
          child: Text(
            player.avatarEmoji,
            style: const TextStyle(fontSize: 80),
          ),
        ),
        Center(
          child: Text(
            player.nickname,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            'Подсказки: ${player.hintLanguage == 'ru' ? 'Русский' : 'English'}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text('Опыт'),
                trailing: Text('${player.xp} XP'),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Уроки'),
                trailing: Text('${player.completedLessonsCount}/10'),
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('Серия'),
                trailing: Text('${player.streak} дней'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            await StorageService.clearPlayer();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
              ),
              (_) => false,
            );
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Сбросить прогресс'),
        ),
      ],
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Soft terrain patches.
    final patches = [
      Rect.fromCircle(
        center: Offset(size.width * .16, 150),
        radius: 100,
      ),
      Rect.fromCircle(
        center: Offset(size.width * .83, 360),
        radius: 130,
      ),
      Rect.fromCircle(
        center: Offset(size.width * .20, 640),
        radius: 120,
      ),
      Rect.fromCircle(
        center: Offset(size.width * .82, 850),
        radius: 150,
      ),
    ];

    for (int i = 0; i < patches.length; i++) {
      paint.color = i.isEven
          ? const Color(0xFFDCEDE4)
          : const Color(0xFFE2F0E8);
      canvas.drawCircle(
        patches[i].center,
        patches[i].width / 2,
        paint,
      );
    }

    // Tiny decorative dots make the map feel alive without covering the path.
    paint.color = Colors.white.withOpacity(.55);
    for (int i = 0; i < 42; i++) {
      final x = (i * 73.0) % size.width;
      final y = (i * 137.0 + 30) % size.height;
      canvas.drawCircle(Offset(x, y), 2.2 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPathPainter extends CustomPainter {
  final List<int> completedLessons;

  const _MapPathPainter({required this.completedLessons});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    final points = List.generate(10, (i) {
      final x = i.isEven ? size.width * .25 : size.width * .72;
      final y = 78.0 + i * 96.0;
      return Offset(x, y);
    });

    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middleY = (previous.dy + current.dy) / 2;
      path.cubicTo(
        previous.dx,
        middleY,
        current.dx,
        middleY,
        current.dx,
        current.dy,
      );
    }

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withOpacity(.06);

    final road = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(.88);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.primary.withOpacity(.22);

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, road);
    canvas.drawPath(path, inner);
  }

  @override
  bool shouldRepaint(covariant _MapPathPainter oldDelegate) =>
      !listEquals(oldDelegate.completedLessons, completedLessons);
}
