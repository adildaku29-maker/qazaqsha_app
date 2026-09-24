import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/lesson_database.dart';

class LessonScreen extends StatefulWidget {
  final String topic, level;
  final int lessonNumber;
  const LessonScreen({super.key, required this.topic, required this.level, this.lessonNumber=1});
  @override State<LessonScreen> createState()=>_LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late LessonPack pack;
  UserProfile? profile;
  final speech=SpeechService();
  final storage=StorageService();
  final db=LessonDatabase.instance;
  final answer=TextEditingController();
  int phase=0,index=0,correct=0;
  bool listening=false,recognizing=false,done=false;
  String feedback='';
  List<String> selected=[],shuffled=[];
  Timer? maxTimer,ampTimer;
  bool stopping=false,checkingAmplitude=false;
  DateTime? started,lastSpeech;

  String get lang=>profile?.language??'ru';
  String tx(String ru,String en,String kk)=>lang=='en'?en:lang=='kk'?kk:ru;

  @override void initState(){
    super.initState();
    pack=lessonFor(widget.topic,lesson:widget.lessonNumber);
    _load();
  }
  Future<void> _load()async{
    profile=await UserProfileService().profile;
    await speech.init();
    if(mounted)setState((){});
  }
  @override void dispose(){
    maxTimer?.cancel(); ampTimer?.cancel();
    speech.cancel(); answer.dispose(); speech.dispose(); super.dispose();
  }

  String norm(String s)=>s.toLowerCase().replaceAll('ё','е').replaceAll(RegExp(r'[.!?,;:—–-]'),' ').replaceAll(RegExp(r'\s+'),' ').trim();

  void advance(){
    if(index<2){
      index++; feedback=''; answer.clear(); selected=[]; shuffled=[];
    }else{
      index=0; phase++; feedback=''; answer.clear(); selected=[]; shuffled=[];
    }
    setState((){});
  }

  Future<void> wordAnswer(String value)async{
    if(value==pack.words[index].tr(lang)){
      correct++; setState(()=>feedback=tx('Правильно!','Correct!','Дұрыс!'));
      await Future.delayed(const Duration(milliseconds:220));
      if(mounted)advance();
    }else{
      setState(()=>feedback=tx('Не совсем. Попробуй ещё.','Not quite. Try again.','Қайта көр.'));
    }
  }

  Future<void> sentenceAnswer()async{
    if(selected.join(' ')==pack.sentences[index].kk){
      correct++; setState(()=>feedback=tx('Отлично!','Excellent!','Керемет!'));
      await Future.delayed(const Duration(milliseconds:220));
      if(mounted)advance();
    }else{
      setState(()=>feedback=tx('Порядок слов неверный.','Word order is not right.','Сөздердің реті дұрыс емес.'));
    }
  }

  Future<void> fillAnswer(String value)async{
    if(value==pack.words[index].kk){
      correct++; setState(()=>feedback=tx('Верно!','Correct!','Дұрыс!'));
      await Future.delayed(const Duration(milliseconds:220));
      if(mounted)advance();
    }else{
      setState(()=>feedback=tx('Попробуй ещё.','Try again.','Қайта көр.'));
    }
  }

  Future<void> listen(String target)async{
    if(listening){
      if(stopping||recognizing)return;
      await stopListen(target); return;
    }
    if(!await speech.init())return;
    setState((){listening=true;recognizing=false;feedback='';});
    stopping=false; started=DateTime.now(); lastSpeech=started;
    maxTimer?.cancel(); ampTimer?.cancel();
    maxTimer=Timer(const Duration(seconds:15),(){
      if(mounted&&listening&&!stopping&&!recognizing)stopListen(target);
    });
    ampTimer=Timer.periodic(const Duration(milliseconds:150),(_)async{
      if(!mounted||!listening||stopping||recognizing||checkingAmplitude)return;
      checkingAmplitude=true;
      try{
        final a=await speech.getRecorderAmplitude();
        if(!mounted||!listening||stopping||recognizing)return;
        final s=started;if(s==null)return;
        final now=DateTime.now();
        if(now.difference(s)<const Duration(milliseconds:700))return;
        if(a>-42)lastSpeech=now;
        else if(now.difference(lastSpeech??s)>=const Duration(milliseconds:900))await stopListen(target);
      }catch(_){
      }finally{checkingAmplitude=false;}
    });
    try{
      await speech.listen(onText:(text){
        if(text.trim().isNotEmpty)_recognized(text,target);
      });
    }catch(e){
      maxTimer?.cancel();ampTimer?.cancel();
      if(mounted)setState((){
        listening=false;recognizing=false;
        feedback=tx('Ошибка микрофона: ','Microphone error: ','Микрофон қатесі: ')+e.toString();
      });
    }
  }

  Future<void> stopListen(String target)async{
    if(stopping||recognizing)return;
    stopping=true;maxTimer?.cancel();ampTimer?.cancel();
    if(mounted)setState(()=>recognizing=true);
    try{
      final text=await speech.stop();
      if(text!=null&&text.trim().isNotEmpty)_recognized(text,target);
      else if(mounted)setState((){
        listening=false;recognizing=false;
        feedback=tx('Речь не распознана.','Speech not recognized.','Сөз танылмады.');
      });
    }catch(e){
      if(mounted)setState((){
        listening=false;recognizing=false;
        feedback=tx('Ошибка распознавания.','Recognition error.','Тану қатесі.');
      });
    }finally{stopping=false;}
  }

  void _recognized(String text,String target){
    if(!mounted)return;
    final n=norm(text),e=norm(target);
    final words=e.split(' ').where((w)=>w.length>2).toList();
    final hit=phase==5
      ?words.isNotEmpty&&words.where(n.contains).length>=max(1,(words.length*.45).ceil())
      :(n==e||words.every(n.contains));
    if(hit){
      correct++;
      setState((){listening=false;recognizing=false;feedback=tx('Отлично!','Great!','Керемет!');});
      if(index==2)Future.delayed(const Duration(milliseconds:300),(){if(mounted)advance();});
    }else{
      setState((){listening=false;recognizing=false;feedback=tx('Я услышал: ','I heard: ','Мен естідім: ')+text;});
    }
  }

  Future<void> finish()async{
    if(done)return;
    done=true;
    final percent=((correct/15)*100).round();
    final grade=percent>90?5:percent>75?4:percent>=60?3:0;
    await db.saveResult(topic:widget.topic,lesson:widget.lessonNumber,score:percent,grade:grade);
    if(grade>=3)await storage.addProgress(
      xpAdd:pack.words.length*5+pack.sentences.length*8+pack.dialogue.length*10+30,
      lessonAdd:1,wordAdd:pack.words.length);
    if(mounted)setState(()=>phase=6);
  }

  @override Widget build(BuildContext context){
    if(profile==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(
      appBar:AppBar(
        title:Text(widget.topic+' • '+widget.lessonNumber.toString()+'-урок',style:const TextStyle(fontWeight:FontWeight.w900)),
        actions:[Padding(padding:const EdgeInsets.only(right:16),child:Center(child:Text(
          phase.clamp(0,6).toString()+'/6',style:const TextStyle(color:AppColors.muted))))],
      ),
      body:phase==6?complete():lessonBody(),
    );
  }

  Widget lessonBody(){
    if(phase==2&&shuffled.isEmpty){
      shuffled=pack.sentences[index].kk.split(' ')..shuffle(Random(index+widget.lessonNumber*10));
    }
    return Column(children:[
      LinearProgressIndicator(value:phase/6,minHeight:5),
      Expanded(child:ListView(padding:const EdgeInsets.all(20),children:[
        Text(titles[phase],style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
        const SizedBox(height:8),Text(subtitles[phase],style:const TextStyle(color:AppColors.muted)),
        const SizedBox(height:24),
        if(phase==0)training()
        else if(phase==1)wordQuiz()
        else if(phase==2)sentence()
        else if(phase==3)fill()
        else if(phase==4)speaking()
        else dialogue(),
      ])),
    ]);
  }

  List<String> get titles=>[
    tx('Обучение','Learn','Үйрену'),
    tx('Слова','Words','Сөздер'),
    tx('Собери предложение','Build sentence','Сөйлем құрастыр'),
    tx('Пропущенное слово','Missing word','Жоғалған сөз'),
    tx('Произнеси','Speak','Айт'),
    tx('Диалог с Аишей','Dialogue with Aisha','Айшамен диалог'),
  ];
  List<String> get subtitles=>[
    tx('Сначала запоминаем слова.','First learn the words.','Алдымен сөздерді жаттаймыз.'),
    tx('Выбери правильный перевод.','Choose the correct translation.','Дұрыс аударманы таңда.'),
    tx('Собери фразу из слов.','Build the phrase.','Сөздерден сөйлем құрастыр.'),
    tx('Вспомни слово и вставь его.','Recall and insert the word.','Сөзді есіңе түсіріп, қой.'),
    tx('Произнеси фразу.','Say the phrase.','Сөйлемді айт.'),
    tx('Ответь Аише по-казахски.','Answer Aisha in Kazakh.','Айшаға қазақша жауап бер.'),
  ];

  Widget counter()=>Row(children:[
    Text((index+1).toString()+' / 3',style:const TextStyle(color:AppColors.muted)),
    const SizedBox(width:12),Expanded(child:LinearProgressIndicator(value:(index+1)/3,minHeight:7))
  ]);

  Widget training()=>Column(children:[
    Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(
      color:AppColors.card,borderRadius:BorderRadius.circular(24)),
      child:Text(tx(
        'Запомни слова. Слова из прошлых тем будут возвращаться для повторения.',
        'Learn the words. Previous-topic words will return for spaced review.',
        'Сөздерді жатта. Алдыңғы тақырыптардың сөздері қайталау үшін қайта келеді.',
      ),style:const TextStyle(fontSize:17,height:1.4))),
    const SizedBox(height:12),
    ...pack.words.map((w)=>study(w.kk,w.tr(lang),false)),
    if(pack.reviewWord!=null)study(
      pack.reviewWord!.kk,
      tx('Повторение: '+pack.reviewWord!.ru,'Review: '+pack.reviewWord!.en,'Қайталау: '+pack.reviewWord!.kk),
      true),
    const SizedBox(height:10),
    FilledButton(onPressed:()=>setState(()=>phase=1),
      child:SizedBox(width:double.infinity,child:Center(child:Text(tx('Начать задания','Start exercises','Тапсырмаларды бастау'))))),
  ]);

  Widget study(String kk,String tr,bool review)=>Card(child:Padding(
    padding:const EdgeInsets.all(16),
    child:Row(children:[
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(review?tx('Повторение','Review','Қайталау'):tx('Новое слово','New word','Жаңа сөз'),
          style:const TextStyle(color:AppColors.muted,fontSize:12)),
        Text(kk,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),
        Text(tr,style:const TextStyle(color:AppColors.muted)),
      ])),
      IconButton(onPressed:()=>speech.speak(kk),
        icon:const Icon(Icons.volume_up_rounded,color:AppColors.teal)),
    ])));

  Widget wordQuiz(){
    final w=pack.words[index];
    final options=[w.tr(lang),...pack.words.where((x)=>x!=w).map((x)=>x.tr(lang))]
      ..shuffle(Random(index+30));
    return Column(children:[
      counter(),const SizedBox(height:20),
      Text(w.kk,style:const TextStyle(fontSize:36,fontWeight:FontWeight.w900)),
      const SizedBox(height:20),
      ...options.map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),
        child:ListTile(onTap:()=>wordAnswer(x),tileColor:AppColors.card,
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),title:Text(x)))),
      if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]);
  }

  Widget sentence(){
    final s=pack.sentences[index];
    return Column(children:[
      counter(),const SizedBox(height:18),
      Text(s.tr(lang),textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted,fontSize:18)),
      const SizedBox(height:18),
      Container(width:double.infinity,padding:const EdgeInsets.all(12),
        decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),
        child:Wrap(spacing:8,children:selected.map((x)=>Chip(label:Text(x))).toList())),
      const SizedBox(height:15),
      Wrap(spacing:8,runSpacing:8,children:shuffled.where((x)=>!selected.contains(x))
        .map((x)=>ActionChip(label:Text(x),onPressed:()=>setState(()=>selected.add(x)))).toList()),
      FilledButton(onPressed:selected.isEmpty?null:sentenceAnswer,
        child:Text(tx('Проверить','Check','Тексеру'))),
      TextButton(onPressed:()=>setState(()=>selected=[]),
        child:Text(tx('Очистить','Clear','Тазалау'))),
      if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]);
  }

  Widget fill(){
    final w=pack.words[index];final s=pack.sentences[index];
    final options=[w.kk,...pack.words.where((x)=>x!=w).map((x)=>x.kk)]
      ..shuffle(Random(index+90));
    return Column(children:[
      counter(),const SizedBox(height:22),
      Text(s.kk.replaceFirst(w.kk,'_____'),
        style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900),textAlign:TextAlign.center),
      const SizedBox(height:10),Text(s.tr(lang),style:const TextStyle(color:AppColors.muted)),
      const SizedBox(height:22),
      ...options.map((x)=>Padding(padding:const EdgeInsets.only(bottom:10),
        child:ListTile(onTap:()=>fillAnswer(x),tileColor:AppColors.card,
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),
          title:Text(x,textAlign:TextAlign.center)))),
      if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]);
  }

  Widget speaking(){
    final s=pack.sentences[index];
    return Column(children:[
      counter(),const SizedBox(height:22),
      Text(s.kk,textAlign:TextAlign.center,style:const TextStyle(fontSize:29,fontWeight:FontWeight.w900)),
      IconButton(onPressed:()=>speech.speak(s.kk),
        icon:const Icon(Icons.volume_up_rounded,color:AppColors.teal,size:30)),
      Text(s.tr(lang),style:const TextStyle(color:AppColors.muted)),
      const SizedBox(height:25),
      CircleAvatar(radius:44,backgroundColor:AppColors.teal.withValues(alpha:.15),
        child:recognizing?const Icon(Icons.hourglass_top_rounded,color:AppColors.teal,size:38)
          :IconButton(iconSize:40,onPressed:()=>listen(s.kk),
            icon:Icon(listening?Icons.stop:Icons.mic,color:AppColors.teal))),
      const SizedBox(height:12),
      Text(recognizing?tx('Распознаём речь…','Recognizing…','Танып жатырмыз…')
        :tx('Нажми и произнеси.','Tap and speak.','Басып айт.')),
      if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]);
  }

  Widget dialogue(){
    final d=pack.dialogue[index];
    final expected=d.answer.replaceAll('{name}',profile!.nickname);
    return Column(children:[
      counter(),const SizedBox(height:20),
      Container(width:double.infinity,padding:const EdgeInsets.all(18),
        decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),
        child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Аиша',style:TextStyle(color:AppColors.teal,fontWeight:FontWeight.w800)),
          const SizedBox(height:8),Text(d.q(lang),style:const TextStyle(fontSize:18)),
          IconButton(onPressed:()=>speech.speak(d.question),
            icon:const Icon(Icons.volume_up_rounded,color:AppColors.teal)),
        ])),
      const SizedBox(height:18),
      TextField(controller:answer,onChanged:(_)=>setState((){}),
        decoration:InputDecoration(hintText:'Қазақша...',filled:true,fillColor:AppColors.card,
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(20),borderSide:BorderSide.none))),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        IconButton(onPressed:()=>listen(expected),
          icon:recognizing?const Icon(Icons.hourglass_top_rounded,color:AppColors.teal)
            :Icon(listening?Icons.stop_circle:Icons.mic,color:AppColors.teal,size:34)),
        FilledButton(onPressed:answer.text.trim().isEmpty?null:()=>_recognized(answer.text,expected),
          child:Text(tx('Проверить','Check','Тексеру'))),
      ]),
      if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]);
  }

  Widget complete(){
    final percent=((correct/15)*100).round();
    final grade=percent>90?5:percent>75?4:percent>=60?3:0;
    final passed=grade>=3;
    return Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(
      mainAxisAlignment:MainAxisAlignment.center,children:[
        Text(passed?'🎉':'💪',style:const TextStyle(fontSize:76)),
        Text(passed?tx('Урок пройден!','Lesson passed!','Сабақ өтті!')
          :tx('Урок не пройден','Lesson not passed','Сабақ өтпеді'),
          style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900),textAlign:TextAlign.center),
        const SizedBox(height:10),Text(percent.toString()+'%',
          style:const TextStyle(fontSize:34,color:AppColors.gold,fontWeight:FontWeight.w900)),
        if(passed)Text('Оценка: '+grade.toString(),
          style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
        const SizedBox(height:12),
        Text(passed?tx('Результат сохранён. Следующий урок открыт.','Result saved. Next lesson unlocked.','Нәтиже сақталды. Келесі сабақ ашылды.')
          :tx('Нужно минимум 60%. Пройди урок ещё раз.','You need at least 60%. Retry the lesson.','Кемінде 60% керек. Сабақты қайта өт.'),
          textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)),
        const SizedBox(height:25),
        FilledButton(onPressed:()=>Navigator.pop(context),
          child:Text(tx('Вернуться к карте','Back to map','Картаға оралу'))),
      ])));
  }
}
