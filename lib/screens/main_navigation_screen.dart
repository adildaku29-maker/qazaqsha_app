import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/qazaqsha_content.dart';
import '../services/storage_service.dart';
import 'ai_dialogue_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int tab=0; final storage=StorageService();
  @override Widget build(BuildContext context) {
    final pages=[_Home(storage:storage),const _Lessons(),const _Achievements(),const _Profile()];
    return Scaffold(body:SafeArea(child:pages[tab]),bottomNavigationBar:NavigationBar(
      selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),
      destinations:const [
        NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Басты бет'),
        NavigationDestination(icon:Icon(Icons.menu_book_outlined),selectedIcon:Icon(Icons.menu_book),label:'Сабақтар'),
        NavigationDestination(icon:Icon(Icons.emoji_events_outlined),selectedIcon:Icon(Icons.emoji_events),label:'Жетістіктер'),
        NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Профиль'),
      ],
    ));
  }
}
class _Home extends StatelessWidget {
  final StorageService storage; const _Home({required this.storage});
  @override Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future:Future.wait<dynamic>([storage.xp,storage.streak,storage.lessons]),
      builder:(context,snapshot) {
        final v=snapshot.data??<dynamic>[0,1,0];
        return ListView(padding:const EdgeInsets.fromLTRB(20,18,20,30),children:[
          Row(children:[
            const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text('Қош келдің, Әділ! 👋',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),
              Text('Қазақша сөйлей баста.',style:TextStyle(color:AppColors.muted)),
            ])),
            Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(18)),child:Text('🔥 '+v[1].toString(),style:const TextStyle(fontWeight:FontWeight.w800))),
          ]),
          const SizedBox(height:22),
          Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.navy2,Color(0xFF0B4A4B)]),borderRadius:BorderRadius.circular(28)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('БҮГІНГІ МИССИЯ',style:TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
            const SizedBox(height:10),const Text('10 минут қазақша',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
            const SizedBox(height:15),const LinearProgressIndicator(value:.62,minHeight:9),const SizedBox(height:9),
            Text(v[0].toString()+' XP • '+v[2].toString()+' сабақ',style:const TextStyle(color:AppColors.muted)),
          ])),
          const SizedBox(height:18),
          InkWell(
            onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AiDialogueScreen(topic:'Танысу',level:'A1'))),
            borderRadius:BorderRadius.circular(24),
            child:Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(24)),child:const Row(children:[
              Text('🤖',style:TextStyle(fontSize:34)),SizedBox(width:14),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('AI-мен сөйлесу',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
                Text('Тірі диалог • A1',style:TextStyle(color:AppColors.muted)),
              ])),Icon(Icons.arrow_forward_ios_rounded,size:17,color:AppColors.teal),
            ])),
          ),
          const SizedBox(height:20),const Text('Оқу жолы',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:10),
          ...topics.map((t)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(
            onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AiDialogueScreen(topic:t.title,level:t.level))),
            tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
            leading:Text(t.emoji,style:const TextStyle(fontSize:28)),title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w800)),
            subtitle:Text(t.level+' • '+t.words.length.toString()+' сөз'),
            trailing:Text('+'+t.xp.toString()+' XP',style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
          ))),
        ]);
      },
    );
  }
}
class _Lessons extends StatelessWidget {
  const _Lessons();
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Сабақтар',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('A1 → A2 → B1',style:TextStyle(color:AppColors.muted)),const SizedBox(height:20),
    ...topics.map((t)=>Padding(padding:const EdgeInsets.only(bottom:10),child:ListTile(
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AiDialogueScreen(topic:t.title,level:t.level))),
      tileColor:AppColors.card,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20)),
      leading:Text(t.emoji,style:const TextStyle(fontSize:30)),title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w800)),
      subtitle:Text(t.subtitle),trailing:Text(t.level,style:const TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ))),
  ]);
}
class _Achievements extends StatelessWidget {
  const _Achievements();
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Жетістіктер',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const SizedBox(height:18),
    ...achievements.map((a){final k=a.keys.first;return Card(child:ListTile(leading:CircleAvatar(child:Text(k)),title:Text(a[k]!),subtitle:const Text('Жалғастыр!')));}),
  ]);
}
class _Profile extends StatelessWidget {
  const _Profile();
  @override Widget build(BuildContext context)=>FutureBuilder<List<dynamic>>(
    future:Future.wait<dynamic>([StorageService().xp,StorageService().lessons,StorageService().words]),
    builder:(context,snapshot){final v=snapshot.data??<dynamic>[0,0,0];return ListView(padding:const EdgeInsets.all(20),children:[
      const CircleAvatar(radius:48,backgroundColor:AppColors.card,child:Text('🦅',style:TextStyle(fontSize:42))),
      const SizedBox(height:14),const Center(child:Text('Әділ',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900))),
      const Center(child:Text('Қазақ тілін үйренуші',style:TextStyle(color:AppColors.muted))),const SizedBox(height:25),
      Row(children:[_metric('XP',v[0].toString()),_metric('Сабақ',v[1].toString()),_metric('Сөз',v[2].toString())]),const SizedBox(height:22),
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(24)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Батыр жолы',style:TextStyle(fontSize:20,fontWeight:FontWeight.w900)),SizedBox(height:10),Text('🛡️ Бастауыш батыр'),
        Text('Келесі деңгей: Момышұлы',style:TextStyle(color:AppColors.gold)),SizedBox(height:14),LinearProgressIndicator(value:.28),
      ])),
    ]);},
  );
}
Widget _metric(String a,String b)=>Expanded(child:Container(margin:const EdgeInsets.only(right:7),padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(20)),child:Column(children:[Text(b,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),Text(a,style:const TextStyle(color:AppColors.muted))])));
