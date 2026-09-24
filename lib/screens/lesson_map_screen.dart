import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/lesson_database.dart';
import 'lesson_screen.dart';

class LessonMapScreen extends StatefulWidget{
  final String language;
  const LessonMapScreen({super.key,required this.language});
  @override State<LessonMapScreen> createState()=>_LessonMapScreenState();
}
class _LessonMapScreenState extends State<LessonMapScreen>{
  Map<String,int> grades={};
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{grades=await LessonDatabase.instance.grades();if(mounted)setState((){});}
  int grade(String topic,int n)=>grades[topic+'_u'+n.toString()]??0;
  bool unlocked(int topicIndex,int lesson){
    if(topicIndex==0&&lesson==1)return true;
    if(lesson>1)return grade(topics[topicIndex].title,lesson-1)>=3;
    return grade(topics[topicIndex-1].title,4)>=3;
  }
  String tr(String ru,String en,String kk)=>widget.language=='en'?en:widget.language=='kk'?kk:ru;

  @override Widget build(BuildContext context){
    return Scaffold(
      body:RefreshIndicator(
        onRefresh:_load,
        child:ListView(padding:const EdgeInsets.fromLTRB(18,20,18,40),children:[
          Row(children:[
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(tr('Твой путь','Your path','Сенің жолың'),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
              const SizedBox(height:4),
              Text(tr('Проходи уроки по порядку — следующий откроется после результата 3+.',
                'Complete lessons in order — the next opens after a grade of 3+.',
                'Сабақтарды ретімен өт — келесі сабақ 3+ бағадан кейін ашылады.'),
                style:const TextStyle(color:AppColors.muted)),
            ])),
            Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(18)),child:const Text('🗺️',style:TextStyle(fontSize:25))),
          ]),
          const SizedBox(height:22),
          ...List.generate(topics.length,(topicIndex)=>_topic(topicIndex)),
        ]),
      ),
    );
  }

  Widget _topic(int topicIndex){
    final topic=topics[topicIndex];
    return Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(
        gradient:const LinearGradient(colors:[AppColors.navy2,Color(0xFF0B4A4B)]),
        borderRadius:BorderRadius.circular(24)),
        child:Row(children:[
          Text(topic.emoji,style:const TextStyle(fontSize:34)),const SizedBox(width:12),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(topic.title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900)),
            Text(topic.subtitle,style:const TextStyle(color:AppColors.muted)),
          ])),
          Text(topic.level,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900)),
        ])),
      const SizedBox(height:10),
      ...List.generate(4,(i)=>_node(topicIndex,i+1)),
      if(topicIndex<topics.length-1)Container(height:24,width:4,color:AppColors.teal.withValues(alpha:.25)),
      const SizedBox(height:8),
    ]);
  }

  Widget _node(int topicIndex,int lesson){
    final topic=topics[topicIndex];
    final g=grade(topic.title,lesson);
    final open=unlocked(topicIndex,lesson);
    final passed=g>=3;
    final current=open&&!passed;
    final align=lesson.isOdd?Alignment.centerLeft:Alignment.centerRight;
    final title=tr('Урок '+lesson.toString(),'Lesson '+lesson.toString(),'Сабақ '+lesson.toString());
    return Align(alignment:align,child:Padding(padding:const EdgeInsets.symmetric(vertical:5,horizontal:lesson.isOdd?4:24),child:InkWell(
      borderRadius:BorderRadius.circular(24),
      onTap:!open?null:()async{
        await Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(topic:topic.title,level:topic.level,lessonNumber:lesson)));
        _load();
      },
      child:Container(width:MediaQuery.sizeOf(context).width*.78,padding:const EdgeInsets.all(14),
        decoration:BoxDecoration(
          color:open?AppColors.card:AppColors.navy2.withValues(alpha:.65),
          borderRadius:BorderRadius.circular(24),
          border:Border.all(color:current?AppColors.teal:Colors.transparent,width:2),
        ),
        child:Row(children:[
          Container(width:54,height:54,decoration:BoxDecoration(
            shape:BoxShape.circle,color:passed?AppColors.teal:open?AppColors.teal.withValues(alpha:.16):AppColors.navy),
            child:Center(child:Icon(
              passed?Icons.check_rounded:open?Icons.play_arrow_rounded:Icons.lock_rounded,
              color:passed?Colors.white:open?AppColors.teal:AppColors.muted))),
          const SizedBox(width:13),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(title,style:TextStyle(fontWeight:FontWeight.w900,color:open?Colors.white:AppColors.muted)),
            const SizedBox(height:4),
            Text(open?tr('Новые слова • тесты • речь','New words • tests • speaking','Жаңа сөздер • тесттер • сөйлеу'):tr('Сначала пройди предыдущий урок','Complete the previous lesson first','Алдымен алдыңғы сабақты өт'),
              style:const TextStyle(color:AppColors.muted,fontSize:12)),
          ])),
          if(g>0)Container(width:38,height:38,decoration:BoxDecoration(color:AppColors.gold.withValues(alpha:.14),shape:BoxShape.circle),
            child:Center(child:Text(g.toString(),style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900,fontSize:17))))
          else if(open)const Icon(Icons.chevron_right_rounded,color:AppColors.muted),
        ]),
      ),
    )));
  }
}
