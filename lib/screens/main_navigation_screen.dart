import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/qazaqsha_content.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../ui/app_text.dart';
import 'lesson_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState()=>_MainNavigationScreenState();
}
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int tab=0; final storage=StorageService();
  @override Widget build(BuildContext context)=>FutureBuilder<UserProfile>(
    future:UserProfileService().profile,
    builder:(context,s){
      final p=s.data??const UserProfile(nickname:'',language:'ru',character:'🦅');
      final pages=[_Home(storage:storage,profile:p),_Lessons(language:p.language),_Achievements(language:p.language),_Profile(profile:p)];
      return Scaffold(body:SafeArea(child:pages[tab]),bottomNavigationBar:NavigationBar(
        selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
        destinations:[
          NavigationDestination(icon:const Icon(Icons.home_outlined),selectedIcon:const Icon(Icons.home),label:AppText.get('home',p.language)),
          NavigationDestination(icon:const Icon(Icons.menu_book_outlined),selectedIcon:const Icon(Icons.menu_book),label:AppText.get('lessons',p.language)),
          NavigationDestination(icon:const Icon(Icons.emoji_events_outlined),selectedIcon:const Icon(Icons.emoji_events),label:AppText.get('achievements',p.language)),
          NavigationDestination(icon:const Icon(Icons.person_outline),selectedIcon:const Icon(Icons.person),label:AppText.get('profile',p.language)),
        ],
      ));
    },
  );
}
class _Home extends StatelessWidget {
  final StorageService storage; final UserProfile profile;
  const _Home({required this.storage,required this.profile});
  @override Widget build(BuildContext context)=>FutureBuilder<List<dynamic>>(
    future:Future.wait<dynamic>([storage.xp,storage.streak,storage.lessons]),
    builder:(context,snapshot){
      final v=snapshot.data??<dynamic>[0,1,0]; final l=profile.language;
      return ListView(padding:const EdgeInsets.fromLTRB(20,18,20,30),children:[
        Row(children:[
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('${AppText.get('welcome',l)}, ${profile.nickname}! 👋',style:const TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
            Text(AppText.get('learn',l),style:const TextStyle(color:AppColors.muted)),
          ])),
          Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(18)),child:Text('${profile.character} 🔥 ${v[1]}',style:const TextStyle(fontWeight:FontWeight.w800))),
        ]),
        const SizedBox(height:22),
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.navy2,Color(0xFF0B4A4B)]),borderRadius:BorderRadius.circular(28)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(AppText.get('mission',l),style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
          const SizedBox(height:10),const Text('10 минут қазақша',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
          const SizedBox(height:15),const LinearProgressIndicator(value:.62,minHeight:9),const SizedBox(height:9),
          Text('${v[0]} XP • ${v[2]} ${AppText.get('lesson',l)}',style:const TextStyle(color:AppColors.muted)),
        ])),
        const SizedBox(height:18),
        const SizedBox(height:18),
        const SizedBox(height:20),Text(AppText.get('path',l),style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),
        Text(AppText.get('lessons_sub',l),style:const TextStyle(color:AppColors.muted)),const SizedBox(height:10),
        ...topics.map((t)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(
          onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(topic:t.title,level:t.level))),
          tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
          leading:Text(t.emoji,style:const TextStyle(fontSize:28)),title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w800)),
          subtitle:Text('${t.level} • ${t.words.length} ${AppText.get('words',l)}'),
          trailing:Text('+${t.xp} XP',style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
        ))),
      ]);
    },
  );
}
class _Lessons extends StatelessWidget {
  final String language; const _Lessons({required this.language});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(AppText.get('lessons',language),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),
    Text(AppText.get('lessons_sub',language),style:const TextStyle(color:AppColors.muted)),const SizedBox(height:20),
    ...topics.map((t)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AiDialogueScreen(topic:t.title,level:t.level))),
      tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
      leading:Text(t.emoji,style:const TextStyle(fontSize:30)),title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w800)),
      subtitle:Text(t.subtitle),trailing:Text(t.level,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ))),
  ]);
}
class _Achievements extends StatelessWidget {
  final String language; const _Achievements({required this.language});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(AppText.get('achievements',language),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:18),
    ...achievements.map((a){final k=a.keys.first;return Card(child:ListTile(leading:CircleAvatar(child:Text(k)),title:Text(a[k]!),subtitle:Text(AppText.get('continue',language))));}),
  ]);
}
class _Profile extends StatelessWidget {
  final UserProfile profile; const _Profile({required this.profile});
  @override Widget build(BuildContext context)=>FutureBuilder<List<dynamic>>(
    future:Future.wait<dynamic>([StorageService().xp,StorageService().lessons,StorageService().words]),
    builder:(context,snapshot){final v=snapshot.data??<dynamic>[0,0,0];return ListView(padding:const EdgeInsets.all(20),children:[
      CircleAvatar(radius:48,backgroundColor:AppColors.card,child:Text(profile.character,style:const TextStyle(fontSize:42))),
      const SizedBox(height:14),Center(child:Text(profile.nickname,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900))),
      Center(child:Text('Qazaqsha • ${profile.language.toUpperCase()}',style:const TextStyle(color:AppColors.muted))),const SizedBox(height:25),
      Row(children:[_metric('XP',v[0].toString()),_metric(AppText.get('lesson',profile.language),v[1].toString()),_metric(AppText.get('words',profile.language),v[2].toString())]),const SizedBox(height:22),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Батыр жолы',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),
        Text('${profile.character} Бастауыш батыр'),const Text('Келесі деңгей: Момышұлы',style:TextStyle(color:AppColors.gold)),
        const SizedBox(height:14),const LinearProgressIndicator(value:.28),
      ])),
    ]);},
  );
}
Widget _metric(String a,String b)=>Expanded(child:Container(margin:const EdgeInsets.only(right:7),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:Column(children:[Text(b,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),Text(a,style:const TextStyle(color:AppColors.muted))])));
