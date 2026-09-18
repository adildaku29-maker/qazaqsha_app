import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';

class LessonScreen extends StatefulWidget{
  final String topic,level;
  const LessonScreen({super.key,required this.topic,required this.level});
  @override State<LessonScreen> createState()=>_LessonScreenState();
}
class _LessonScreenState extends State<LessonScreen>{
  late LessonPack pack;
  UserProfile? profile;
  final speech=SpeechService();
  final storage=StorageService();
  final answer=TextEditingController();
  int phase=0,index=0,correct=0;
  List<String> selected=[];
  List<String> shuffled=[];
  bool listening=false,done=false;
  String feedback='';

  String get lang=>profile?.language??'ru';
  String tx(String ru,String en,String kk)=>lang=='en'?en:lang=='kk'?kk:ru;

  @override void initState(){super.initState();pack=lessonFor(widget.topic);_load();}
  Future<void> _load() async{final p=await UserProfileService().profile;profile=p;await speech.init();if(mounted)setState((){});}
  @override void dispose(){answer.dispose();speech.stop();super.dispose();}

  void next(){
    setState(()=>feedback='');
    if(phase==0){phase=1;index=0;return;}
    if(phase==1){if(index<pack.words.length-1){index++;}else{phase=2;index=0;_prepareSentence();}return;}
    if(phase==2){if(selected.join(' ')==pack.sentences[index].kk){correct++;feedback=tx('Дұрыс!','Correct!','Дұрыс!');if(index<pack.sentences.length-1){index++;_prepareSentence();}else{phase=3;index=0;}}else{feedback=tx('Ещё раз собери.','Try again.','Қайта құрастыр.');}return;}
    if(phase==3){if(index<pack.sentences.length-1){index++;return;}phase=4;index=0;answer.clear();return;}
    if(phase==4){_finish();}
  }

  void _prepareSentence(){selected=[];shuffled=pack.sentences[index].kk.split(' ')..shuffle(Random(index+7));}

  Future<void> _listen({required String target}) async{
    if(listening){await speech.stop();if(mounted)setState(()=>listening=false);return;}
    final ok=await speech.init();if(!ok)return;
    if(mounted)setState(()=>listening=true);
    try{
      await speech.listen(onText:(text){
        if(text.trim().isEmpty)return;
        final normalized=text.toLowerCase().replaceAll(RegExp(r'[.!?,]'),'').trim();
        final expected=target.toLowerCase().replaceAll(RegExp(r'[.!?,]'),'').trim();
        final hit=normalized==expected || expected.split(' ').where((w)=>w.length>2).every(normalized.contains);
        if(hit && mounted){setState((){listening=false;feedback=tx('Отлично!','Great pronunciation!','Жақсы айттың!');});speech.stop();}
      });
    }catch(_){if(mounted)setState(()=>listening=false);}
  }

  Future<void> _finish() async{
    if(done)return;
    done=true;
    await storage.addProgress(xpAdd:pack.words.length*5+pack.sentences.length*8+pack.dialogue.length*10+20,lessonAdd:1,wordAdd:pack.words.length);
    if(mounted)setState(()=>phase=5);
  }

  @override Widget build(BuildContext context){
    if(profile==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(title:Text('${widget.topic} • ${widget.level}',style:const TextStyle(fontWeight:FontWeight.w900)),actions:[Padding(padding:const EdgeInsets.only(right:16),child:Center(child:Text('${phase.clamp(0,5)}/5',style:const TextStyle(color:AppColors.muted))))]),
      body:phase==5?_complete():_body(),
    );
  }

  Widget _body(){
    return Column(children:[
      LinearProgressIndicator(value:phase/5,minHeight:5),
      Expanded(child:ListView(padding:const EdgeInsets.fromLTRB(20,22,20,30),children:[
        Text(_phaseTitle(),style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
        const SizedBox(height:8),Text(_phaseSub(),style:const TextStyle(color:AppColors.muted,fontSize:15)),
        const SizedBox(height:24),
        if(phase==0)_training() else if(phase==1)_wordQuiz() else if(phase==2)_sentenceBuilder() else if(phase==3)_speaking() else _dialogue(),
      ])),
      if(phase==0)SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,4,20,14),child:FilledButton(onPressed:next,child:SizedBox(width:double.infinity,child:Center(child:Text(tx('Начать упражнения','Start exercises','Жаттығуларды бастау'))))))),
      if(phase==2)SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,4,20,14),child:FilledButton(onPressed:selected.isEmpty?null:next,child:SizedBox(width:double.infinity,child:Center(child:Text(tx('Проверить','Check','Тексеру'))))))),
      if(phase==3)SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,4,20,14),child:FilledButton(onPressed:next,child:SizedBox(width:double.infinity,child:Center(child:Text(tx('Далее','Continue','Жалғастыру'))))))),
      if(phase==4)SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(20,4,20,14),child:FilledButton(onPressed:answer.text.trim().isEmpty?null:next,child:SizedBox(width:double.infinity,child:Center(child:Text(index==2?tx('Завершить','Finish','Аяқтау'):tx('Ответить','Answer','Жауап беру'))))))),
    ]);
  }

  String _phaseTitle()=>[
    tx('Обучение','Learn','Үйрену'),tx('Слова','Words','Сөздер'),tx('Собери предложение','Build the sentence','Сөйлем құрастыр'),tx('Произнеси','Speak','Айт'),tx('Диалог с Аишей','Dialogue with Aisha','Айшамен диалог')
  ][phase];
  String _phaseSub()=>[
    tx('Сначала изучи тему. Здесь нет теста — просто знакомимся с материалом.','Learn first. No test yet — just study the material.','Алдымен тақырыпты үйрен. Әзірге тест жоқ.'),tx('Выбери правильное слово 3 раза.','Choose the correct word 3 times.','Дұрыс сөзді 3 рет таңда.'),tx('Собери казахское предложение из слов.','Build the Kazakh sentence from the words.','Қазақша сөйлемді сөздерден құрастыр.'),tx('Произнеси 3 фразы.','Say 3 phrases aloud.','3 сөйлемді дауыстап айт.'),tx('Аиша говорит первой. Ты отвечаешь по-казахски. 3 коротких диалога.','Aisha speaks first. You answer in Kazakh. 3 short dialogues.','Айша бірінші сөйлейді. Сен қазақша жауап бересің. 3 қысқа диалог.')
  ][phase];

  Widget _training()=>Column(children:[
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(tx('Мини-урок','Mini lesson','Шағын сабақ'),style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
      const SizedBox(height:12),
      Text(tx('Сначала учим материал: три слова и три готовые фразы для знакомства.','First learn the material: three words and three ready-made phrases for introductions.','Алдымен материалды үйренеміз: танысуға арналған үш сөз және үш дайын сөйлем.'),style:const TextStyle(fontSize:17,height:1.4)),
    ])),
    const SizedBox(height:14),
    ...pack.words.map((w)=>_studyCard(w.kk,w.tr(lang),'word')),
    const SizedBox(height:6),
    ...pack.sentences.map((s)=>_studyCard(s.kk,s.tr(lang),'sentence')),
  ]);

  Widget _studyCard(String kk,String tr,String type)=>Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(type=='word'?tx('Слово','Word','Сөз'):tx('Фраза','Phrase','Сөйлем'),style:const TextStyle(color:AppColors.muted,fontSize:12)),
    const SizedBox(height:5),Text(kk,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
    const SizedBox(height:5),Text(tr,style:const TextStyle(color:AppColors.muted,fontSize:16)),
    Align(alignment:Alignment.centerRight,child:IconButton(onPressed:()=>speech.speak(kk),icon:const Icon(Icons.volume_up_rounded,color:AppColors.teal))),
  ]));

  Widget _wordQuiz(){
    final w=pack.words[index];
    final options=[w.tr(lang),...pack.words.where((x)=>x!=w).map((x)=>x.tr(lang))]..shuffle(Random(index+30));
    return Column(children:[
      _counter(index+1,3),const SizedBox(height:20),
      Text(w.kk,style:const TextStyle(fontSize:36,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),Text(tx('Что это значит?','What does it mean?','Бұл нені білдіреді?'),style:const TextStyle(color:AppColors.muted)),
      const SizedBox(height:22),
      ...options.map((o)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(
        onTap:()=>setState((){if(o==w.tr(lang)){correct++;feedback=tx('Правильно!','Correct!','Дұрыс!');if(index<2){index++;}else{phase=2;index=0;_prepareSentence();}}else{feedback=tx('Не совсем. Попробуй ещё.','Not quite. Try again.','Дұрыс емес. Қайта көр.');}}}),
        tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),title:Text(o),
      ))),
      if(feedback.isNotEmpty)Padding(padding:const EdgeInsets.all(10),child:Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))),
    ]);
  }

  Widget _counter(int n,int total)=>Row(children:[Text('${n} / ${total}',style:const TextStyle(color:AppColors.muted,fontWeight:FontWeight.w700)),const SizedBox(width:12),Expanded(child:LinearProgressIndicator(value:n/total,minHeight:7))]);

  Widget _sentenceBuilder(){
    final s=pack.sentences[index];
    return Column(children:[
      _counter(index+1,3),const SizedBox(height:20),
      Text(s.tr(lang),style:const TextStyle(fontSize:18,color:AppColors.muted),textAlign:TextAlign.center),
      const SizedBox(height:22),
      Container(width:double.infinity,minHeight:70,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:Wrap(spacing:8,runSpacing:8,children:selected.map((x)=>Chip(label:Text(x))).toList())),
      const SizedBox(height:18),
      Wrap(spacing:8,runSpacing:10,children:shuffled.where((x)=>!selected.contains(x)).map((x)=>ActionChip(label:Text(x),onPressed:()=>setState(()=>selected.add(x)))).toList()),
      if(feedback.isNotEmpty)Padding(padding:const EdgeInsets.all(12),child:Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))),
      TextButton(onPressed:()=>setState(()=>selected=[]),child:Text(tx('Очистить','Clear','Тазалау'))),
    ]);
  }

  Widget _speaking(){
    final s=pack.sentences[index];
    return Column(children:[
      _counter(index+1,3),const SizedBox(height:25),
      Text(s.kk,style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900),textAlign:TextAlign.center),
      const SizedBox(height:10),Text(s.tr(lang),style:const TextStyle(color:AppColors.muted,fontSize:16),textAlign:TextAlign.center),
      const SizedBox(height:28),
      CircleAvatar(radius:42,backgroundColor:AppColors.teal.withValues(alpha:.15),child:IconButton(iconSize:40,onPressed:()=>_listen(target:s.kk),icon:Icon(listening?Icons.stop:Icons.mic,color:AppColors.teal))),
      const SizedBox(height:14),Text(tx('Нажми и произнеси фразу.','Tap and say the phrase.','Басып, сөйлемді айт.'),style:const TextStyle(color:AppColors.muted)),
      if(feedback.isNotEmpty)Padding(padding:const EdgeInsets.all(14),child:Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))),
    ]);
  }

  Widget _dialogue(){
    final d=pack.dialogue[index];
    final q=d.q(lang).replaceAll('{name}',profile!.nickname);
    final a=d.a(lang).replaceAll('{name}',profile!.nickname);
    return Column(children:[
      _counter(index+1,3),const SizedBox(height:20),
      Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const CircleAvatar(child:Text('👩')),const SizedBox(width:10),Expanded(child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Аиша',style:TextStyle(fontWeight:FontWeight.w800,color:AppColors.teal)),const SizedBox(height:6),Text(q,style:const TextStyle(fontSize:17)),
      ])))]),
      const SizedBox(height:18),
      Text(tx('Твой ответ по-казахски:','Your answer in Kazakh:','Қазақша жауап бер:'),style:const TextStyle(color:AppColors.muted)),
      const SizedBox(height:10),
      Text(a,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w800),textAlign:TextAlign.center),
      const SizedBox(height:16),
      Row(children:[IconButton(onPressed:()=>_listen(target:a),icon:Icon(listening?Icons.stop_circle:Icons.mic,color:AppColors.teal,size:34)),Expanded(child:TextField(controller:answer,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Қазақша...',filled:true,fillColor:AppColors.card,border:OutlineInputBorder(borderRadius:BorderRadius.circular(20),borderSide:BorderSide.none))))]),
      if(feedback.isNotEmpty)Padding(padding:const EdgeInsets.all(12),child:Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))),
    ]);
  }

  Widget _complete()=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Text('🎉',style:TextStyle(fontSize:80)),const SizedBox(height:18),
    Text(tx('Урок завершён!','Lesson complete!','Сабақ аяқталды!'),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900),textAlign:TextAlign.center),
    const SizedBox(height:10),Text('+${pack.words.length*5+pack.sentences.length*8+pack.dialogue.length*10+20} XP',style:const TextStyle(color:AppColors.gold,fontSize:24,fontWeight:FontWeight.w900)),
    const SizedBox(height:28),Text(tx('Ты прошёл обучение, 3 задания со словами, 3 предложения, 3 произношения и 3 диалога с Аишей.','You completed the training, 3 word tasks, 3 sentence tasks, 3 speaking tasks and 3 dialogues with Aisha.','Оқыту, 3 сөз тапсырмасы, 3 сөйлем, 3 айтылым және Айшамен 3 диалог аяқталды.'),textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted,height:1.4)),
    const SizedBox(height:30),FilledButton(onPressed:()=>Navigator.pop(context),child:Text(tx('Вернуться к урокам','Back to lessons','Сабақтарға оралу'))),
  ]));
}
