import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/lesson_content.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/lesson_database.dart';
import '../services/qazaqsha_database.dart';
import 'streak_screen.dart';

class LessonScreen extends StatefulWidget{
 final String topic,level; final int lessonNumber;
 const LessonScreen({super.key,required this.topic,required this.level,this.lessonNumber=1});
 @override State<LessonScreen> createState()=>_LessonScreenState();
}
class _LessonScreenState extends State<LessonScreen>{
 UserProfile? profile; final speech=SpeechService(); final audio=AudioService.instance;
 final storage=StorageService(); final db=LessonDatabase.instance; final statsDb=QazaqshaDatabase.instance;
 late LessonPack pack; ExamPack? exam;
 int phase=0,index=0,correct=0; bool done=false,listening=false,recognizing=false,stopping=false,checking=false;
 String feedback=''; Timer? maxTimer,ampTimer; DateTime? started,lastSpeech;
 String? pairLeft; final Set<String> pairDone={};
 final answer=TextEditingController();

 bool get isExam=>exam!=null;
 int get totalTasks=>isExam?15:10;
 List<TranslationQuestion> get translations=>isExam?exam!.translations:pack.translations;
 List<MatchPair> get pairs=>isExam?exam!.pairs:pack.pairs;
 List<FillQuestion> get fills=>isExam?exam!.fills:pack.fills;
 List<SpeakingPrompt> get speaking=>isExam?exam!.speaking:[...pack.speaking];
 String get lang=>profile?.language??'ru';
 String tx(String ru,String en,String kk)=>lang=='en'?en:lang=='kk'?kk:ru;

 @override void initState(){super.initState();pack=lessonFor(widget.topic,lesson:widget.lessonNumber);exam=widget.lessonNumber==5?examFor(widget.topic):null;_load();}
 Future<void> _load()async{profile=await UserProfileService().profile;await speech.init();if(mounted)setState((){});}
 @override void dispose(){maxTimer?.cancel();ampTimer?.cancel();speech.cancel();speech.dispose();answer.dispose();super.dispose();}

 String norm(String s)=>s.toLowerCase().replaceAll('ё','е').replaceAll(RegExp(r'[.!?,;:—–-]'),' ').replaceAll(RegExp(r'\s+'),' ').trim();
 void resetStep(){feedback='';pairLeft=null;pairDone.clear();answer.clear();}
 void advance(){final lastPhase=isExam?3:4;if(index<currentCount()-1){index++;resetStep();}else if(phase<lastPhase){phase++;index=0;resetStep();}else{finish();return;}setState((){});}
 int currentCount()=>phase==(isExam?0:1)?translations.length:phase==(isExam?1:2)?1:phase==(isExam?2:3)?fills.length:speaking.length;

 Future<void> chooseTranslation(int n)async{
   if(n==translations[index].correct){correct++;setState(()=>feedback=tx('Правильно!','Correct!','Дұрыс!'));await Future.delayed(const Duration(milliseconds:220));if(mounted)advance();}
   else setState(()=>feedback=tx('Не совсем. Попробуй ещё.','Not quite. Try again.','Қайта көр.'));
 }
 Future<void> chooseFill(int n)async{
   if(n==fills[index].correct){correct++;setState(()=>feedback=tx('Верно!','Correct!','Дұрыс!'));await Future.delayed(const Duration(milliseconds:220));if(mounted)advance();}
   else setState(()=>feedback=tx('Попробуй ещё.','Try again.','Қайта көр.'));
 }
 void selectPair(String kk){
   if(pairDone.contains(kk))return;
   setState(()=>pairLeft=kk);
 }
 void selectPairTranslation(String ru){
   if(pairLeft==null)return;
   final p=pairs.firstWhere((x)=>x.kk==pairLeft);
   if(p.ru==ru){
     pairDone.add(p.kk);pairLeft=null;
     if(pairDone.length==pairs.length){correct++;feedback=tx('Отлично! Все пары найдены.','Excellent! All pairs matched.','Керемет! Барлық жұп табылды.');Future.delayed(const Duration(milliseconds:300),(){if(mounted)advance();});}
     else setState(()=>feedback='');
   }else setState(()=>feedback=tx('Пока не совпало. Попробуй ещё.','Not a match yet. Try again.','Сәйкес емес. Қайта көр.'));
 }

 Future<void> listen(String target)async{
   if(listening){if(stopping||recognizing)return;await stopListen(target);return;}
   if(!await speech.init())return;
   setState((){listening=true;recognizing=false;feedback='';});stopping=false;started=DateTime.now();lastSpeech=started;
   maxTimer?.cancel();ampTimer?.cancel();
   maxTimer=Timer(const Duration(seconds:15),(){if(mounted&&listening&&!stopping&&!recognizing)stopListen(target);});
   ampTimer=Timer.periodic(const Duration(milliseconds:150),(_)async{
     if(!mounted||!listening||stopping||recognizing||checking)return;checking=true;
     try{final a=await speech.getRecorderAmplitude();if(!mounted||!listening||stopping||recognizing)return;final s=started;if(s==null)return;final now=DateTime.now();if(now.difference(s)<const Duration(milliseconds:700))return;if(a>-42)lastSpeech=now;else if(now.difference(lastSpeech??s)>=const Duration(milliseconds:900))await stopListen(target);}catch(_){}finally{checking=false;}
   });
   try{await speech.listen(onText:(text){if(text.trim().isNotEmpty)_recognized(text,target);});}
   catch(e){maxTimer?.cancel();ampTimer?.cancel();if(mounted)setState((){listening=false;recognizing=false;feedback=tx('Ошибка микрофона','Microphone error','Микрофон қатесі');});}
 }
 Future<void> stopListen(String target)async{
   if(stopping||recognizing)return;stopping=true;maxTimer?.cancel();ampTimer?.cancel();if(mounted)setState(()=>recognizing=true);
   try{final text=await speech.stop();if(text!=null&&text.trim().isNotEmpty)_recognized(text,target);else if(mounted)setState((){listening=false;recognizing=false;feedback=tx('Речь не распознана.','Speech not recognized.','Сөз танылмады.');});}
   catch(_){if(mounted)setState((){listening=false;recognizing=false;feedback=tx('Ошибка распознавания.','Recognition error.','Тану қатесі.');});}finally{stopping=false;}
 }
 void _recognized(String text,String target){
   if(!mounted)return;final n=norm(text);final expected=target.contains('[Ваше имя]')?'сәлеметсіз бе менің атым танысқаныма қуаныштымын':norm(target);final ws=expected.split(' ').where((x)=>x.length>2).toList();final hit=ws.isNotEmpty&&ws.where(n.contains).length>=max(1,(ws.length*.45).ceil());
   if(hit){correct++;setState((){listening=false;recognizing=false;feedback=tx('Отлично!','Great!','Керемет!');});Future.delayed(const Duration(milliseconds:300),(){if(mounted)advance();});}
   else setState((){listening=false;recognizing=false;feedback=tx('Я услышал: ','I heard: ','Мен естідім: ')+text;});
 }
 Future<void> finish()async{
   if(done)return;done=true;final percent=((correct/totalTasks)*100).round();final grade=percent>90?5:percent>75?4:percent>=60?3:0;
   final wasPassed=await db.isPassed(widget.topic,widget.lessonNumber);await db.saveResult(topic:widget.topic,lesson:widget.lessonNumber,score:percent,grade:grade);
   if(!wasPassed&&grade>=3){final xp=isExam?120:pack.words.length*5+pack.speaking.length*8+30;await statsDb.recordCompletion(xp:xp,words:isExam?0:pack.words.length);await storage.addProgress(xpAdd:xp,lessonAdd:1,wordAdd:isExam?0:pack.words.length);}
   if(mounted)setState(()=>phase=5);
 }
 @override Widget build(BuildContext context){
   if(profile==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));
   final stepLabel=phase<5 ? (isExam ? (phase+1).toString() : phase.toString()) + '/4' : '';
   return Scaffold(
     appBar:AppBar(
       title:Text(isExam?'Танысу • Экзамен':'Танысу • '+widget.lessonNumber.toString()+'-урок',style:const TextStyle(fontWeight:FontWeight.w900)),
       actions:[Padding(padding:const EdgeInsets.only(right:16),child:Center(child:Text(stepLabel,style:const TextStyle(color:AppColors.muted))))],
     ),
     body:phase==5?complete():body(),
   );
 }
 Widget body()=>Column(children:[LinearProgressIndicator(value:(phase+1)/4,minHeight:5),Expanded(child:ListView(padding:const EdgeInsets.all(20),children:[Text(title(),style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:7),Text(subtitle(),style:const TextStyle(color:AppColors.muted)),const SizedBox(height:22),if(!isExam&&phase==0)trainingBlock()else if((isExam&&phase==0)||(!isExam&&phase==1))translationBlock()else if((isExam&&phase==1)||(!isExam&&phase==2))matchBlock()else if((isExam&&phase==2)||(!isExam&&phase==3))fillBlock()else speakingBlock()]))]);
 String title(){if(!isExam&&phase==0)return tx('Словарь урока','Lesson vocabulary','Сабақ сөздігі');final i=isExam?phase:phase-1;return (isExam?[tx('Проверка знаний','Knowledge check','Білімді тексеру'),tx('Найди пары','Match the pairs','Жұпты тап'),tx('Вставь слово в диалоге','Complete the dialogue','Диалогты толықтыр'),tx('Финальный голосовой экзамен','Final speaking exam','Қорытынды дауыс емтиханы')]:[tx('Как переводится?','What does it mean?','Қалай аударылады?'),tx('Найди пару','Match the pairs','Жұпты тап'),tx('Вставь пропущенное слово','Fill the missing word','Жоғалған сөзді қой'),tx('Повтори по голосовому','Repeat by voice','Дауыспен қайтала')])[i];}
 String subtitle(){if(!isExam&&phase==0)return tx('Сначала выучи слова и фразы. Нажимай на 🔊, чтобы услышать казахское произношение.','First learn the words and phrases. Tap 🔊 to hear Kazakh pronunciation.','Алдымен сөздер мен сөз тіркестерін үйрен. 🔊 белгісін басып, қазақша айтылуын тыңда.');final i=isExam?phase:phase-1;return (isExam?[tx('5 вопросов','5 questions','5 сұрақ'),tx('5 пар','5 pairs','5 жұп'),tx('3 задания','3 tasks','3 тапсырма'),tx('2 голосовых задания','2 speaking tasks','2 дауыс тапсырмасы')]:[tx('3 задания с 4 вариантами','3 questions with 4 options','4 нұсқалы 3 сұрақ'),tx('1 задание на 3 пары','1 task with 3 pairs','3 жұптан тұратын 1 тапсырма'),tx('3 задания','3 tasks','3 тапсырма'),tx('3 задания','3 speaking tasks','3 дауыс тапсырма')])[i];}
 Widget sound(String audioName)=>IconButton(onPressed:()=>audio.speakAsset(audioName),icon:const Icon(Icons.volume_up_rounded,color:AppColors.teal));
 Widget progress(int n,int total)=>Row(children:[Text('$n / $total',style:const TextStyle(color:AppColors.muted)),const SizedBox(width:12),Expanded(child:LinearProgressIndicator(value:n/total,minHeight:7))]);
 Widget trainingBlock(){return Column(children:[...pack.words.map((w)=>Card(child:ListTile(title:Text(w.kk,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),subtitle:Text(w.ru,style:const TextStyle(color:AppColors.muted)),trailing:sound(w.audio)))),const SizedBox(height:12),FilledButton(onPressed:()=>setState(()=>phase=1),child:SizedBox(width:double.infinity,child:Center(child:Text(tx('Начать задания','Start exercises','Тапсырмаларды бастау'))))) ]);}
 Widget translationBlock(){
   final q=translations[index];
   final opts=[...q.ru];
   final order=List.generate(opts.length,(i)=>i)..shuffle(Random(index+(isExam?300:30)));
   return Column(children:[
     progress(index+1,translations.length),
     const SizedBox(height:20),
     Row(mainAxisAlignment:MainAxisAlignment.center,children:[
       Flexible(child:Text(q.kk,textAlign:TextAlign.center,style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900))),
       sound(q.audio),
     ]),
     const SizedBox(height:10),
     Text(q.ruPrompt,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)),
     const SizedBox(height:20),
     ...order.map((i)=>Padding(
       padding:const EdgeInsets.only(bottom:10),
       child:ListTile(onTap:()=>chooseTranslation(i),tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),leading:CircleAvatar(child:Text(String.fromCharCode(65+i))),title:Text(opts[i])),
     )),
     if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
   ]);
 }
 Widget matchBlock(){
   final left=pairs.map((p)=>p.kk).toList();
   final right=pairs.map((p)=>p.ru).toList()..shuffle(Random(isExam?77:17));
   return Column(children:[
     progress(pairDone.length,pairs.length),
     const SizedBox(height:18),
     if(pairLeft!=null)Text(tx('Выбрано: $pairLeft — теперь выбери перевод','Selected: $pairLeft — now choose the translation','Таңдалды: $pairLeft — енді аудармасын таңда'),style:const TextStyle(color:AppColors.teal,fontWeight:FontWeight.w800)),
     const SizedBox(height:12),
     ...left.map((kk)=>Padding(
       padding:const EdgeInsets.only(bottom:8),
       child:ListTile(onTap:()=>selectPair(kk),tileColor:pairDone.contains(kk)?AppColors.teal.withValues(alpha:.16):pairLeft==kk?AppColors.teal.withValues(alpha:.22):AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),title:Text(kk),leading:soundIconFor(kk)),
     )),
     const Divider(height:25),
     ...right.map((ru)=>Padding(
       padding:const EdgeInsets.only(bottom:8),
       child:ListTile(onTap:()=>selectPairTranslation(ru),tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),title:Text(ru)),
     )),
     if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
   ]);
 }
 Widget soundIconFor(String kk){final p=pairs.firstWhere((x)=>x.kk==kk);return sound(p.audio);}
 Widget soundIconFor(String kk){final p=pairs.firstWhere((x)=>x.kk==kk);return sound(p.audio);}
 Widget fillBlock(){
   final q=fills[index];final order=List.generate(q.options.length,(i)=>i)..shuffle(Random(index+90));return Column(children:[progress(index+1,fills.length),const SizedBox(height:20),Row(mainAxisAlignment:MainAxisAlignment.center,children:[Flexible(child:Text(q.sentence,textAlign:TextAlign.center,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w900))),sound(q.audio)]),const SizedBox(height:10),Text(q.ru,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)),const SizedBox(height:20),...order.map((i)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(onTap:()=>chooseFill(i),tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),title:Text(q.options[i],textAlign:TextAlign.center)))),if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))]);}
 Widget speakingBlock(){final list=speaking;final s=list[index];return Column(children:[progress(index+1,list.length),const SizedBox(height:20),Row(mainAxisAlignment:MainAxisAlignment.center,children:[Flexible(child:Text(s.kk,textAlign:TextAlign.center,style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900))),sound(s.audio)]),const SizedBox(height:8),Text(s.ru,textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)),const SizedBox(height:25),CircleAvatar(radius:46,backgroundColor:AppColors.teal.withValues(alpha:.15),child:recognizing?const Icon(Icons.hourglass_top_rounded,color:AppColors.teal,size:38):IconButton(iconSize:42,onPressed:()=>listen(s.kk),icon:Icon(listening?Icons.stop:Icons.mic,color:AppColors.teal))),const SizedBox(height:12),Text(recognizing?tx('Распознаём речь…','Recognizing…','Танып жатырмыз…'):tx('Нажми и произнеси.','Tap and speak.','Басып айт.')),if(feedback.isNotEmpty)Text(feedback,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800))]);}
 Widget examSpeakingExtra(){return const SizedBox.shrink();}
 Widget complete(){final percent=((correct/totalTasks)*100).round();final grade=percent>90?5:percent>75?4:percent>=60?3:0;final passed=grade>=3;return Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(isExam?'🏆':'🎉',style:const TextStyle(fontSize:76)),Text(passed?tx(isExam?'Экзамен сдан!':'Урок пройден!','Passed!','Өтті!'):tx(isExam?'Экзамен не сдан':'Урок не пройден','Not passed','Өтпеді'),style:const TextStyle(fontSize:29,fontWeight:FontWeight.w900),textAlign:TextAlign.center),const SizedBox(height:10),Text('$percent%',style:const TextStyle(fontSize:34,color:AppColors.gold,fontWeight:FontWeight.w900)),if(passed)Text('Оценка: $grade',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:12),Text(passed?tx('Результат сохранён.','Result saved.','Нәтиже сақталды.'):tx('Нужно минимум 60%. Попробуй ещё раз.','You need at least 60%. Retry.','Кемінде 60% керек. Қайта өт.'),textAlign:TextAlign.center,style:const TextStyle(color:AppColors.muted)),const SizedBox(height:25),FilledButton(onPressed:(){if(passed&&widget.topic=='Танысу'&&widget.lessonNumber==1)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>StreakScreen(language:lang,goal:profile?.goal??'')));else Navigator.pop(context);},child:Text(tx('Продолжить','Continue','Жалғастыру')))])));}}
