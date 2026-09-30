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

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:AppColors.navy,
    body:Stack(children:[
      Positioned.fill(
        child:LayoutBuilder(
          builder:(context,constraints){
            return InteractiveViewer(
              minScale:.75,
              maxScale:2.2,
              alignment:Alignment.topCenter,
              boundaryMargin:const EdgeInsets.symmetric(vertical:120,horizontal:30),
              clipBehavior:Clip.hardEdge,
              child:FittedBox(
                fit:BoxFit.contain,
                alignment:Alignment.topCenter,
                child:SizedBox(
                  width:430,
                  height:774,
                  child:Stack(children:[
                    Positioned.fill(
                      child:SvgPicture.asset(
                        'assets/map/qazaqsha_map.svg',
                        fit:BoxFit.fill,
                        semanticsLabel:'Qazaqsha оқу картасы',
                      ),
                    ),
                    ...List.generate(
                      topics.length > 5 ? 5 : topics.length,
                      _topicNode,
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      SafeArea(child:Padding(
        padding:const EdgeInsets.fromLTRB(16,12,16,0),
        child:Row(children:[
          Expanded(child:_glass(child:Row(children:[
            const Text('🔥',style:TextStyle(fontSize:24)),const SizedBox(width:8),
            Text('$streak ${tr('день подряд','day streak','күн қатарынан')}',style:const TextStyle(fontWeight:FontWeight.w900)),
          ]))),
          const SizedBox(width:10),
          _glass(child:const Icon(Icons.map_rounded,color:AppColors.teal)),
        ]),
      )),
      Positioned(left:16,right:16,bottom:14,child:_glass(
        padding:const EdgeInsets.symmetric(horizontal:16,vertical:12),
        child:Row(children:[
          const Icon(Icons.swipe_rounded,color:AppColors.teal),const SizedBox(width:10),
          Expanded(child:Text(tr('Нажимай на локации — проходи уроки и открывай новые ветки.','Tap a location, complete lessons and unlock new branches.','Локацияны таңдап, сабақтарды өтіп, жаңа жолдарды аш.'),style:const TextStyle(fontSize:12,color:AppColors.muted))),
        ]),
      )),
    ]),
  );

  Widget _glass({required Widget child,EdgeInsetsGeometry? padding})=>Container(
    padding:padding??const EdgeInsets.all(12),
    decoration:BoxDecoration(color:AppColors.navy.withValues(alpha:.88),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white.withValues(alpha:.08)),boxShadow:const[BoxShadow(blurRadius:18,offset:Offset(0,8),color:Colors.black26)]),
    child:child,
  );

  Widget _topicNode(int index){
    final t=topics[index],open=unlocked(index),passed=grade(t.title,lessonCountFor(t.title))>=3;
    final p=_positions[index%_positions.length];
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

  static const _positions=<Offset>[
    Offset(215,676), // Танысу / двор
    Offset(309,112), // Үй
    Offset(128,264), // Мектеп
    Offset(108,430), // Тамақ
    Offset(365,260), // Денсаулық
    Offset(330,540),Offset(250,600),Offset(365,620),Offset(175,560),Offset(335,430),Offset(185,360),Offset(335,430),Offset(185,360),
  ];
}
