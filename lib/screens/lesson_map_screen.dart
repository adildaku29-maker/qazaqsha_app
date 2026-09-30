import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/lesson_database.dart';
import '../services/qazaqsha_database.dart';
import 'lesson_screen.dart';

class LessonMapScreen extends StatefulWidget {
  final String language;
  const LessonMapScreen({super.key, required this.language});

  @override
  State<LessonMapScreen> createState() => _LessonMapScreenState();
}

class _LessonMapScreenState extends State<LessonMapScreen> {
  Map<String, int> grades = {};
  int streak = 0;

  // Map order: bottom -> top.
  static const stops = <_MapStop>[
    _MapStop('Танысу', 'Танысу', '👋', Icons.waving_hand_rounded),
    _MapStop('Үй', 'Үй', '🏠', Icons.home_rounded),
    _MapStop('Денсаулық', 'Аурухана', '🏥', Icons.local_hospital_rounded),
    _MapStop('Тамақ', 'Тамақ', '🍲', Icons.restaurant_rounded),
    _MapStop('Мектеп', 'Мектеп', '🏫', Icons.school_rounded),
  ];

  static const stopCenters = <Offset>[
    Offset(215, 1035),
    Offset(105, 835),
    Offset(320, 635),
    Offset(110, 435),
    Offset(300, 235),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    grades = await LessonDatabase.instance.grades();
    streak = (await QazaqshaDatabase.instance.stats())['streak'] ?? 0;
    if (mounted) setState(() {});
  }

  int grade(String topic, int lesson) => grades['${topic}_u$lesson'] ?? 0;

  bool unlocked(String topic) {
    if (topic == 'Танысу') return true;
    if (topic == 'Үй') return grade('Танысу', 4) >= 3;
    return grade('Үй', 5) >= 3;
  }

  int nextLesson(String topic) {
    for (var i = 1; i <= 4; i++) {
      if (grade(topic, i) < 3) return i;
    }
    return 4;
  }

  String tr(String ru, String en, String kk) =>
      widget.language == 'en' ? en : widget.language == 'kk' ? kk : ru;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapBackgroundPainter())),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(10, 74, 10, 36),
                child: Center(
                  child: SizedBox(
                    width: 430,
                    height: 1160,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _AdventureRoutePainter(stopCenters),
                          ),
                        ),
                        ...List.generate(stops.length, _buildStop),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  children: [
                    _glass(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 7),
                          Text(
                            '$streak ${tr('күн қатарынан', 'day streak', 'күн қатарынан')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _glass(
                      padding: const EdgeInsets.all(11),
                      child: const Icon(
                        Icons.map_rounded,
                        color: AppColors.teal,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glass({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .09)),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Colors.black26),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStop(int index) {
    final stop = stops[index];
    final center = stopCenters[index];
    final open = unlocked(stop.topic);

    return Positioned(
      left: center.dx - 150,
      top: center.dy - 108,
      width: 300,
      height: 210,
      child: Column(
        children: [
          // The four lesson levels are always ABOVE the building.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final lesson = i + 1;
              final passed = grade(stop.topic, lesson) >= 3;
              final active = open && (lesson == 1 || grade(stop.topic, lesson - 1) >= 3);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: _levelButton(
                  lesson,
                  passed: passed,
                  active: active,
                  onTap: active ? () => _openLesson(stop.topic, lesson) : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          _destinationBuilding(stop, open),
          const SizedBox(height: 7),
          Text(
            stop.label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelButton(
    int number, {
    required bool passed,
    required bool active,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: passed
              ? AppColors.teal
              : active
                  ? AppColors.card
                  : AppColors.navy2,
          border: Border.all(
            color: passed
                ? Colors.white
                : active
                    ? AppColors.gold
                    : Colors.white.withValues(alpha: .12),
            width: active || passed ? 2.3 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: .28),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: passed
              ? const Icon(Icons.check_rounded, size: 21)
              : active
                  ? Text(
                      '$number',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    )
                  : const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: Colors.white38,
                    ),
        ),
      ),
    );
  }

  Widget _destinationBuilding(_MapStop stop, bool open) {
    return GestureDetector(
      onTap: open ? () => _openNext(stop.topic) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 142,
        height: 92,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, AppColors.navy2],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: open ? AppColors.gold : Colors.white.withValues(alpha: .10),
            width: open ? 2.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 20,
              offset: Offset(0, 10),
              color: Colors.black26,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -9,
              child: Icon(
                stop.icon,
                size: 82,
                color: Colors.white.withValues(alpha: .035),
              ),
            ),
            Center(
              child: Text(
                stop.emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
            if (!open)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .24),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_rounded, color: Colors.white70, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(String topic, int lesson) async {
    final t = topics.firstWhere((item) => item.title == topic);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          topic: topic,
          level: t.level,
          lessonNumber: lesson,
        ),
      ),
    );
    _load();
  }

  Future<void> _openNext(String topic) async {
    await _openLesson(topic, nextLesson(topic));
  }
}

class _MapStop {
  final String topic;
  final String label;
  final String emoji;
  final IconData icon;

  const _MapStop(this.topic, this.label, this.emoji, this.icon);
}

class _AdventureRoutePainter extends CustomPainter {
  final List<Offset> points;
  const _AdventureRoutePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final dx = (b.dx - a.dx) * .42;
      final dy = (b.dy - a.dy) * .46;
      path.cubicTo(
        a.dx + dx,
        a.dy - dy * .16,
        b.dx - dx,
        b.dy + dy * .16,
        b.dx,
        b.dy,
      );
    }

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final outer = Paint()
      ..color = Colors.white.withValues(alpha: .78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final inner = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, outer);
    canvas.drawPath(path, inner);

    final marker = Paint()..color = Colors.white.withValues(alpha: .75);
    for (final p in points) {
      canvas.drawCircle(p, 4, marker);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureRoutePainter oldDelegate) => false;
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.navy2, AppColors.navy, AppColors.navy2],
      ).createShader(rect);

    canvas.drawRect(rect, paint);

    final glow = Paint()..color = AppColors.teal.withValues(alpha: .035);
    canvas.drawCircle(Offset(size.width * .16, size.height * .25), 190, glow);
    canvas.drawCircle(Offset(size.width * .84, size.height * .65), 230, glow);
  }

  @override
  bool shouldRepaint(covariant _MapBackgroundPainter oldDelegate) => false;
}
