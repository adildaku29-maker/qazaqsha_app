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
  @override State<LessonMapScreen> createState() => _LessonMapScreenState();
}

class _LearningPathPainter extends CustomPainter {
  final List<Offset> points;
  const _LearningPathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: .24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final outer = Paint()
      ..color = Colors.white.withValues(alpha: .68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    final inner = Paint()
      ..color = AppColors.gold.withValues(alpha: .78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final dx = (b.dx - a.dx) * .45;
      final dy = (b.dy - a.dy) * .45;
      path.cubicTo(
        a.dx + dx,
        a.dy + dy * .35,
        b.dx - dx,
        b.dy - dy * .35,
        b.dx,
        b.dy,
      );
    }

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, outer);
    canvas.drawPath(path, inner);
  }

  @override
  bool shouldRepaint(covariant _LearningPathPainter oldDelegate) => false;
}

class _LessonMapScreenState extends State<LessonMapScreen> {
  Map<String,int> grades={};
  int streak=0;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    grades=await LessonDatabase.instance.grades();
    streak=(await QazaqshaDatabase.instance.stats())['streak']??0;
    if(mounted)setState((){});
  }
  int grade(String topic,int lesson)=>grades['${topic}_u$lesson']??0;
  bool unlocked(int index){
    final t=topics[index];
    if(t.requiredAfter==null)return index==0;
    return grade(t.requiredAfter!,lessonCountFor(t.requiredAfter!))>=3;
  }
  String tr(String ru,String en,String kk)=>widget.language=='en'?en:widget.language=='kk'?kk:ru;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The map itself always fills the available screen.
          // FittedBox keeps the SVG and lesson coordinates in the same
          // 430x774 coordinate system, so nothing gets pushed down.
          Align(
            alignment: Alignment.bottomCenter,
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 430,
                height: 774,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SvgPicture.asset(
                      'assets/map/qazaqsha_map.svg',
                      fit: BoxFit.fill,
                      semanticsLabel: 'Qazaqsha оқу картасы',
                    ),
                    CustomPaint(painter: _LearningPathPainter(_positions)),
                    ...List.generate(
                      topics.length > _positions.length ? _positions.length : topics.length,
                      _topicNode,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Clean top HUD. It floats above the map and never changes
          // the map's layout height.
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _glass(
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 23)),
                          const SizedBox(width: 8),
                          Text(
                            '$streak ${tr('күн қатарынан', 'day streak', 'күн қатарынан')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _glass(
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Small instruction card, positioned above the navigation bar.
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: SafeArea(
              top: false,
              child: _glass(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.teal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr(
                          'Басыңыз — сабақты бастаңыз және жаңа жолдарды ашыңыз.',
                          'Tap a location to start a lesson and unlock new paths.',
                          'Локацияны басып, сабақты бастаңыз және жаңа жолдарды ашыңыз.',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _glass({required Widget child,EdgeInsetsGeometry? padding})=>Container(
    padding:padding??const EdgeInsets.all(12),
    decoration:BoxDecoration(color:AppColors.navy.withValues(alpha:.88),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white.withValues(alpha:.08)),boxShadow:const[BoxShadow(blurRadius:18,offset:Offset(0,8),color:Colors.black26)]),
    child:child,
  );

  Widget _topicNode(int index){
    final t=topics[index],open=unlocked(index),passed=grade(t.title,lessonCountFor(t.title))>=3;
    final p=_positions[index];
    return Positioned(left:p.dx-31,top:p.dy-31,child:GestureDetector(
      onTap:open?()=>_openTopic(index):null,
      child:AnimatedContainer(duration:const Duration(milliseconds:220),width:62,height:62,
        decoration:BoxDecoration(shape:BoxShape.circle,color:passed?AppColors.teal:open?AppColors.card:const Color(0xFF8C9685),border:Border.all(color:passed?Colors.white:open?AppColors.gold:Colors.white54,width:open?3:2),boxShadow:open?[BoxShadow(color:AppColors.gold.withValues(alpha:.30),blurRadius:18,spreadRadius:2)]:null),
        child:Center(child:passed?const Icon(Icons.check_rounded,color:Colors.white,size:30):open?Text(t.emoji,style:const TextStyle(fontSize:28)):const Icon(Icons.lock_rounded,color:Colors.white70,size:24)),
      ),
    ));
  }

  Future<void> _openTopic(int index) async {
    final t=topics[index];
    var next=1;
    for(var n=1;n<=4;n++){
      if(grade(t.title,n)<3){next=n;break;}
      next=5;
    }
    await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(topic:t.title,level:t.level,lessonNumber:next)));
    _load();
  }

  // Wide zig-zag route: every lesson has its own visual zone.
  static const _positions=<Offset>[
    Offset(215,700),
    Offset(105,590),
    Offset(300,500),
    Offset(125,405),
    Offset(305,315),
    Offset(135,225),
    Offset(295,145),
    Offset(145,82),
  ];
}
