import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  static const stops = <_MapStop>[
    _MapStop('Танысу', 215, 1035, false),
    _MapStop('Үй', 105, 835, true),
    _MapStop('Денсаулық', 320, 635, true),
    _MapStop('Тамақ', 110, 435, true),
    _MapStop('Мектеп', 300, 235, true),
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

  String tr(String ru, String en, String kk) =>
      widget.language == 'en' ? en : widget.language == 'kk' ? kk : ru;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B9C61),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 16).clamp(300.0, 430.0);
                final height = width * 1160 / 430;
                final scale = width / 430;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 74, bottom: 28),
                  child: Center(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/map/qazaqsha_map.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          ...List.generate(
                            stops.length,
                            (i) => _buildStop(stops[i], scale),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
        color: const Color(0xE6071522),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Colors.black26),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStop(_MapStop stop, double scale) {
    final open = unlocked(stop.topic);

    return Positioned(
      left: (stop.x - 128) * scale,
      top: (stop.y - (stop.hasBuilding ? 146 : 105)) * scale,
      width: 256 * scale,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final lesson = i + 1;
              final passed = grade(stop.topic, lesson) >= 3;
              final active = open &&
                  (lesson == 1 || grade(stop.topic, lesson - 1) >= 3);
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                child: _levelButton(
                  lesson,
                  scale,
                  passed: passed,
                  active: active,
                  onTap: active ? () => _openLesson(stop.topic, lesson) : null,
                ),
              );
            }),
          ),
          SizedBox(height: 8 * scale),
          if (stop.hasBuilding)
            SizedBox(
              height: 92 * scale,
              width: 130 * scale,
            ),
          if (!stop.hasBuilding) SizedBox(height: 44 * scale),
        ],
      ),
    );
  }

  Widget _levelButton(
    int number,
    double scale, {
    required bool passed,
    required bool active,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 43 * scale,
        height: 43 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: passed
              ? AppColors.teal
              : active
                  ? const Color(0xFF173827)
                  : const Color(0xCC29443A),
          border: Border.all(
            color: passed
                ? Colors.white
                : active
                    ? AppColors.gold
                    : Colors.white.withValues(alpha: .35),
            width: active || passed ? 2.3 * scale : scale,
          ),
          boxShadow: [
            if (active)
              BoxShadow(
                color: AppColors.gold.withValues(alpha: .42),
                blurRadius: 15 * scale,
                spreadRadius: 1,
              ),
            const BoxShadow(
              color: Colors.black38,
              blurRadius: 7,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: passed
              ? Icon(Icons.check_rounded, size: 21 * scale)
              : active
                  ? Text(
                      '$number',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15 * scale,
                      ),
                    )
                  : Icon(
                      Icons.lock_rounded,
                      size: 16 * scale,
                      color: Colors.white70,
                    ),
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
}

class _MapStop {
  final String topic;
  final double x;
  final double y;
  final bool hasBuilding;

  const _MapStop(this.topic, this.x, this.y, this.hasBuilding);
}
