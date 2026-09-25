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

  int grade(String topic, int lesson) =>
      grades['${topic}_u$lesson'] ?? 0;

  bool unlocked(int topicIndex, int lesson) {
    if (topicIndex == 0 && lesson == 1) return true;
    if (lesson > 1) return grade(topics[topicIndex].title, lesson - 1) >= 3;
    final prev=topics[topicIndex-1].title;
    return grade(prev, lessonCountFor(prev)) >= 3;
  }

  String tr(String ru, String en, String kk) =>
      widget.language == 'en' ? en : widget.language == 'kk' ? kk : ru;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 50),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('Твой путь', 'Your path', 'Сенің жолың'),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tr(
                          'Проходи путь шаг за шагом',
                          'Move forward step by step',
                          'Жолды қадамдап өт',
                        ),
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Center(
                    child: Text('🗺️', style: TextStyle(fontSize: 25)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _streakCard(),
            const SizedBox(height: 24),
            ...List.generate(topics.length, _topic),
          ],
        ),
      ),
    );
  }

  Widget _streakCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.gold.withValues(alpha: .22)),
    ),
    child: Row(children: [
      const Text('🔥', style: TextStyle(fontSize: 30)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$streak ${tr('дн. подряд', 'days in a row', 'күн қатарынан')}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        Text(tr('Пройди урок сегодня, чтобы сохранить огонь', 'Complete a lesson today to keep your streak', 'Жалғастыру үшін бүгін сабақ өт'), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ])),
    ]),
  );

  Widget _topic(int topicIndex) {
    final topic = topics[topicIndex];

    return Column(
      children: [
        // Topic checkpoint/header.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: .35),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(topic.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                topic.level,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Lesson stages connected by a single vertical path.
        ...List.generate(lessonCountFor(topic.title), (i) => _lessonNode(topicIndex, i + 1)),

        if (topicIndex < topics.length - 1)
          Container(
            width: 5,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: .28),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

        const SizedBox(height: 18),
      ],
    );
  }

  Widget _lessonNode(int topicIndex, int lesson) {
    final topic = topics[topicIndex];
    final g = grade(topic.title, lesson);
    final open = unlocked(topicIndex, lesson);
    final passed = g >= 3;
    final current = open && !passed;
    final exam = lesson == 5;
    return Column(children:[
      SizedBox(height:92,child:Stack(alignment:Alignment.center,children:[
        if(lesson < lessonCountFor(topic.title)) Positioned(top:67,bottom:0,child:Container(width:5,decoration:BoxDecoration(color:passed?AppColors.teal.withValues(alpha:.75):AppColors.teal.withValues(alpha:.22),borderRadius:BorderRadius.circular(10)))),
        Positioned(left:18,child:Text('$lesson',style:TextStyle(color:open?AppColors.muted:AppColors.muted.withValues(alpha:.5),fontWeight:FontWeight.w800,fontSize:13))),
        GestureDetector(
          onTap:!open?null:()async{
            await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(topic:topic.title,level:topic.level,lessonNumber:lesson)));
            _load();
          },
          child:AnimatedContainer(
            duration:const Duration(milliseconds:180),
            width:current?72:64,height:current?72:64,
            decoration:BoxDecoration(
              shape:BoxShape.circle,
              color:exam&&open&&!passed?AppColors.gold.withValues(alpha:.16):passed?AppColors.teal:open?AppColors.card:AppColors.navy2,
              border:Border.all(color:exam&&open&&!passed?AppColors.gold:current?AppColors.teal:passed?AppColors.teal.withValues(alpha:.8):AppColors.muted.withValues(alpha:.12),width:current?4:2),
              boxShadow:current?[BoxShadow(color:AppColors.teal.withValues(alpha:.28),blurRadius:18,spreadRadius:2)]:null,
            ),
            child:Center(
              child:passed
                ? const Icon(Icons.check_rounded,color:Colors.white,size:32)
                : open
                  ? (exam ? const Icon(Icons.workspace_premium_rounded,color:AppColors.gold,size:32) : Text('$lesson',style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)))
                  : const Icon(Icons.lock_rounded,color:AppColors.muted,size:25),
            ),
          ),
        ),
        if(g>0) Positioned(right:22,child:Container(width:34,height:34,decoration:BoxDecoration(color:AppColors.gold.withValues(alpha:.15),shape:BoxShape.circle,border:Border.all(color:AppColors.gold.withValues(alpha:.5))),child:Center(child:Text('$g',style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900))))),
      ])),
      Text(lesson==5?tr('Экзамен','Exam','Емтихан'):tr('Урок $lesson','Lesson $lesson','Сабақ $lesson'),style:TextStyle(color:open?Colors.white:AppColors.muted.withValues(alpha:.65),fontWeight:FontWeight.w800,fontSize:12)),
      const SizedBox(height:6),
    ]);
  }
}  }
}
