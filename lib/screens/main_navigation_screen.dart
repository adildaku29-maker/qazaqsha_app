import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/qazaqsha_content.dart';
import '../data/lesson_content.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../services/qazaqsha_database.dart';
import '../ui/app_text.dart';
import 'lesson_map_screen.dart';
import 'lessons_screen.dart';

class MainNavigationScreen extends StatefulWidget{
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState()=>_MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>{
  int tab=0;
  @override Widget build(BuildContext context)=>FutureBuilder<UserProfile>(
    future:UserProfileService().profile,
    builder:(context,s){
      final p=s.data??const UserProfile(nickname:'',language:'ru',character:'🦅');
      final pages=[
        LessonMapScreen(language:p.language),
        LessonsScreen(language:p.language),
        _Achievements(language:p.language),
        _Profile(profile:p),
      ];
      return Scaffold(
        body:SafeArea(child:pages[tab]),
        bottomNavigationBar:NavigationBar(
          selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
          destinations:[
            NavigationDestination(icon:const Icon(Icons.home_outlined),selectedIcon:const Icon(Icons.home),label:AppText.get('home',p.language)),
            NavigationDestination(icon:const Icon(Icons.menu_book_outlined),selectedIcon:const Icon(Icons.menu_book),label:AppText.get('lessons',p.language)),
            NavigationDestination(icon:const Icon(Icons.emoji_events_outlined),selectedIcon:const Icon(Icons.emoji_events),label:AppText.get('achievements',p.language)),
            NavigationDestination(icon:const Icon(Icons.person_outline),selectedIcon:const Icon(Icons.person),label:AppText.get('profile',p.language)),
          ],
        ),
      );
    },
  );
}

class _Achievements extends StatefulWidget{
  final String language;
  const _Achievements({required this.language});
  @override State<_Achievements> createState()=>_AchievementsState();
}

class _AchievementsState extends State<_Achievements>{
  Map<String,int> stats={};
  @override void initState(){super.initState();_load();}
  Future<void> _load()async{
    stats=await QazaqshaDatabase.instance.stats();
    if(mounted)setState((){});
  }
  String tr(String ru,String en,String kk)=>widget.language=='en'?en:widget.language=='kk'?kk:ru;

  @override Widget build(BuildContext context){
    final xp=stats['xp']??0,streak=stats['streak']??0,words=stats['words']??0,lessons=stats['lessons']??0;
    final items=[
      ('🔥',tr('7 дней подряд','7 day streak','7 күн қатарынан'),streak,7),
      ('⚡',tr('1000 XP набрать','Earn 1000 XP','1000 XP жина'),xp,1000),
      ('📚',tr('100 слов выучить','Learn 100 words','100 сөз үйрен'),words,100),
      ('🎙️',tr('10 уроков пройти','Complete 10 lessons','10 сабақ өт'),lessons,10),
      ('💬',tr('25 уроков пройти','Complete 25 lessons','25 сабақ өт'),lessons,25),
      ('🇰🇿',tr('50 уроков пройти','Complete 50 lessons','50 сабақ өт'),lessons,50),
    ];
    return RefreshIndicator(
      onRefresh:_load,
      child:ListView(padding:const EdgeInsets.fromLTRB(20,20,20,40),children:[
        Text(tr('Достижения','Achievements','Жетістіктер'),style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
        const SizedBox(height:6),
        Text(tr('Твой прогресс обновляется после каждого пройденного урока.','Your progress updates after every completed lesson.','Прогресс әр сабақтан кейін жаңартылады.'),style:const TextStyle(color:AppColors.muted)),
        const SizedBox(height:22),
        ...items.map((item){
          final value=item.$3,target=item.$4;
          final progress=(value/target).clamp(0.0,1.0);
          return Container(
            margin:const EdgeInsets.only(bottom:14),
            padding:const EdgeInsets.all(18),
            decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(22)),
            child:Column(children:[
              Row(children:[
                Text(item.$1,style:const TextStyle(fontSize:28)),
                const SizedBox(width:12),
                Expanded(child:Text(item.$2,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900))),
                Text('$value / $target',style:const TextStyle(color:AppColors.muted,fontWeight:FontWeight.w700)),
              ]),
              const SizedBox(height:12),
              ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:progress,minHeight:9)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _Profile extends StatelessWidget{
  final UserProfile profile; const _Profile({required this.profile});
  @override Widget build(BuildContext context)=>FutureBuilder<List<dynamic>>(
    future:Future.wait<dynamic>([StorageService().xp,StorageService().lessons,StorageService().words]),
    builder:(context,snapshot){
      final v=snapshot.data??<dynamic>[0,0,0];
      return ListView(padding:const EdgeInsets.all(20),children:[
        CircleAvatar(radius:48,backgroundColor:AppColors.card,child:Text(profile.character,style:const TextStyle(fontSize:42))),
        const SizedBox(height:14),Center(child:Text(profile.nickname,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900))),
        Center(child:Text('Qazaqsha • '+profile.language.toUpperCase(),style:const TextStyle(color:AppColors.muted))),
        const SizedBox(height:25),
        Row(children:[_metric('XP',v[0].toString()),_metric(AppText.get('lesson',profile.language),v[1].toString()),_metric(AppText.get('words',profile.language),v[2].toString())]),
      ]);
    },
  );
}
Widget _metric(String a,String b)=>Expanded(child:Container(margin:const EdgeInsets.only(right:7),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:Column(children:[Text(b,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),Text(a,style:const TextStyle(color:AppColors.muted))])));
