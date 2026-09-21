import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/speech_service.dart';
import 'lesson_screen.dart';
import '../widgets/aisha_hero.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState()=>_OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen>{
  final speech=SpeechService(); int step=0; String goal=''; String language='ru';
  final goals=['Для работы','Для разговоров','Для путешествий','Для учёбы','Для себя'];
  @override void initState(){super.initState();_say('Привет, я Айша!');}
  Future<void> _say(String text)async{await Future.delayed(const Duration(milliseconds:250));if(mounted)await speech.speak(text);}
  @override void dispose(){speech.dispose();super.dispose();}
  Future<void> _next()async{
    if(step==0){setState(()=>step=1);await _say('Ответь на парочку коротких вопросов — и начнем первый урок.');return;}
    if(step==1){if(goal.isEmpty)return;setState(()=>step=2);await _say('Я буду напоминать вам, чтобы практика вошла в привычку.');return;}
    if(step==2){await _requestNotifications();return;}
    if(step==3){setState(()=>step=4);await _say('Отлично! Приступим к вашему первому 2 минутному уроку!');return;}
    if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const LessonScreen(topic:'Танысу',level:'A1')));
  }
  Future<void> _requestNotifications()async{
    try{await const MethodChannel('qazaqsha/notifications').invokeMethod('requestPermission');}catch(_){}
    if(!mounted)return;setState(()=>step=3);await _say('Вот чего можно достичь за 3 месяца!');
  }
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:AnimatedSwitcher(duration:const Duration(milliseconds:260),child:_page(ValueKey(step)))));
  Widget _page(Key key){switch(step){case 0:return _intro(key);case 1:return _questions(key);case 2:return _notifications(key);case 3:return _threeMonths(key);default:return _firstLesson(key);}}
  Widget _base({required Key key,required Widget child,required String button,VoidCallback? onPressed})=>Padding(key:key,padding:const EdgeInsets.fromLTRB(22,18,22,20),child:Column(children:[
    Align(alignment:Alignment.centerLeft,child:Text('QAZAQSHA',style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900,letterSpacing:2))),
    Expanded(child:child),SizedBox(width:double.infinity,height:56,child:FilledButton(onPressed:onPressed,child:Text(button,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800))))
  ]));
  Widget _intro(Key key)=>_base(key:key,button:'Продолжить',onPressed:_next,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const AishaHero(scale:1.05),const SizedBox(height:4),const Text('Привет, я Айша!',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
    const SizedBox(height:10),const Text('Я помогу тебе начать говорить по-казахски уверенно и без стресса.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted,fontSize:16,height:1.4))
  ]));
  Widget _questions(Key key)=>_base(key:key,button:'Продолжить',onPressed:goal.isEmpty?null:_next,child:ListView(children:[
    const SizedBox(height:8),
    const Align(alignment:Alignment.centerLeft,child:AishaHero(scale:.42)),
    const SizedBox(height:4),
    const Text('Айша',style:TextStyle(color:AppColors.teal,fontWeight:FontWeight.w900,fontSize:15)),
    const SizedBox(height:18),
    const Text('Зачем вы хотите изучить казахский?',style:TextStyle(fontSize:29,fontWeight:FontWeight.w900)),
    const SizedBox(height:10),const Text('Выберите то, что подходит вам. Это поможет настроить путь обучения.',style:TextStyle(color:AppColors.muted,height:1.4)),
    const SizedBox(height:24),...goals.map((g)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(onTap:()=>setState(()=>goal=g),tileColor:goal==g?AppColors.teal.withValues(alpha:.18):AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),leading:Icon(_goalIcon(g),color:goal==g?AppColors.teal:AppColors.muted),title:Text(g,style:const TextStyle(fontWeight:FontWeight.w700)),trailing:goal==g?const Icon(Icons.check_circle,color:AppColors.teal):null)))
  ]));
  IconData _goalIcon(String g){if(g.contains('работ'))return Icons.work_outline;if(g.contains('разговор'))return Icons.forum_outlined;if(g.contains('путеше'))return Icons.flight_takeoff_outlined;if(g.contains('уч'))return Icons.school_outlined;return Icons.favorite_border;}
  Widget _notifications(Key key)=>_base(key:key,button:'Разрешить',onPressed:_next,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Container(width:92,height:92,decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(30)),child:const Icon(Icons.notifications_active_rounded,color:AppColors.gold,size:52)),
    const SizedBox(height:28),const Text('Я буду напоминать вам, чтобы практика вошла в привычку',textAlign:TextAlign.center,style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
    const SizedBox(height:12),const Text('Небольшие напоминания помогут не пропускать занятия.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted,fontSize:16,height:1.4)),
    const SizedBox(height:28),Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:const Row(children:[Icon(Icons.notifications_none_rounded,color:AppColors.teal),SizedBox(width:12),Expanded(child:Text('Разрешить Qazaqsha отправлять вам уведомления?',style:TextStyle(fontWeight:FontWeight.w700))) ]))
  ]));
  Widget _threeMonths(Key key)=>_base(key:key,button:'Продолжить',onPressed:_next,child:ListView(children:[
    const SizedBox(height:25),const Text('Вот чего можно достичь за 3 месяца!',style:TextStyle(fontSize:29,fontWeight:FontWeight.w900)),const SizedBox(height:22),
    _benefit('1','Уверенное общение','Практика речи и понимания на слух без стресса.'),_benefit('2','Расширение словарного запаса','Часто используемые слова и полезные фразы.'),_benefit('3','Привычка заниматься регулярно','Умные напоминания, нескучные уроки и многое другое.')
  ]));
  Widget _benefit(String n,String title,String sub)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(22)),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Container(width:38,height:38,alignment:Alignment.center,decoration:BoxDecoration(color:AppColors.teal,borderRadius:BorderRadius.circular(13)),child:Text(n,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text(sub,style:const TextStyle(color:AppColors.muted,height:1.35))]))
  ]));
  Widget _firstLesson(Key key)=>_base(key:key,button:'Начать урок',onPressed:_next,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const AishaHero(),const SizedBox(height:10),const Text('Отлично!',style:TextStyle(fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Приступим к вашему первому 2 минутному уроку!',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted,fontSize:17))
  ]));
}