import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/lesson_database.dart';
import 'lesson_screen.dart';

class LessonsScreen extends StatefulWidget {
  final String language;
  const LessonsScreen({super.key,required this.language});
  @override State<LessonsScreen> createState()=>_LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>{
  Map<String,int> grades={};
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{
    grades=await LessonDatabase.instance.grades();
    if(mounted)setState((){});
  }
  int grade(String topic,int n)=>grades['${topic}_u$n']??0;
  bool unlocked(int ti,int lesson){
    if(ti==0&&lesson==1)return true;
    if(lesson>1)return grade(topics[ti].title,lesson-1)>=3;
    return grade(topics[ti-1].title,4)>=3;
  }
  String tr(String ru,String en,String kk)=>widget.language=='en'?en:widget.language=='kk'?kk:ru;

  @override Widget build(BuildContext context)=>RefreshIndicator(
    onRefresh:_load,
    child:ListView(
      padding:const EdgeInsets.fromLTRB(20,20,20,40),
      children:[
        Text(tr('Уроки','Lessons','Сабақтар'),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),
        Text(tr('Все уроки и твой результат','All lessons and your results','Барлық сабақтар және нәтижелер'),style:const TextStyle(color:AppColors.muted)),
        const SizedBox(height:22),
        ...List.generate(topics.length,_topic),
      ],
    ),
  );

  Widget _topic(int ti){
    final topic=topics[ti];
    return Container(
      margin:const EdgeInsets.only(bottom:18),
      decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(22)),
      child:Padding(
        padding:const EdgeInsets.fromLTRB(16,16,16,8),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[
            Text(topic.emoji,style:const TextStyle(fontSize:28)),const SizedBox(width:10),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(topic.title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
              Text(topic.subtitle,style:const TextStyle(color:AppColors.muted,fontSize:12)),
            ])),
            Text(topic.level,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900)),
          ]),
          const SizedBox(height:8),
          ...List.generate(4,(i)=>_lesson(ti,i+1)),
        ]),
      ),
    );
  }

  Widget _lesson(int ti,int n){
    final topic=topics[ti];
    final g=grade(topic.title,n);
    final open=unlocked(ti,n);
    return ListTile(
      contentPadding:const EdgeInsets.symmetric(horizontal:4),
      leading:Container(
        width:44,height:44,
        decoration:BoxDecoration(
          shape:BoxShape.circle,
          color:g>=3?AppColors.teal:open?AppColors.teal.withValues(alpha:.13):AppColors.navy2,
        ),
        child:Center(child:Icon(
          g>=3?Icons.check_rounded:open?Icons.play_arrow_rounded:Icons.lock_rounded,
          color:g>=3?Colors.white:open?AppColors.teal:AppColors.muted,
        )),
      ),
      title:Text(tr('Урок $n','Lesson $n','Сабақ $n'),style:const TextStyle(fontWeight:FontWeight.w800)),
      subtitle:Text(g>0?tr('Оценка $g','Grade $g','Баға $g'):open?tr('Нет оценки','Not completed','Бағаланбаған'):tr('Заблокирован','Locked','Құлыптаулы'),
        style:const TextStyle(color:AppColors.muted)),
      trailing:g>0?Container(width:36,height:36,decoration:BoxDecoration(shape:BoxShape.circle,color:AppColors.gold.withValues(alpha:.14)),child:Center(child:Text('$g',style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900)))):null,
      onTap:!open?null:()async{
        await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(topic:topic.title,level:topic.level,lessonNumber:n)));
        _load();
      },
    );
  }
}
