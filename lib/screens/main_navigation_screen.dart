import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/qazaqsha_content.dart';
import '../services/storage_service.dart';
import '../services/user_profile_service.dart';
import '../ui/app_text.dart';
import 'lesson_map_screen.dart';

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
        LessonMapScreen(language:p.language),
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

class _Achievements extends StatelessWidget{
  final String language; const _Achievements({required this.language});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(AppText.get('achievements',language),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:18),
    ...achievements.map((a){final k=a.keys.first;return Card(child:ListTile(leading:CircleAvatar(child:Text(k)),title:Text(a[k]!),subtitle:Text(AppText.get('continue',language))));}),
  ]);
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
