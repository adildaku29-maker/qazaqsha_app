import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../ui/app_text.dart';
import 'main_navigation_screen.dart';

class TutorialScreen extends StatefulWidget {
  final String language;
  const TutorialScreen({super.key,required this.language});
  @override State<TutorialScreen> createState()=>_TutorialScreenState();
}
class _TutorialScreenState extends State<TutorialScreen> {
  int step=0;
  @override Widget build(BuildContext context){
    final items=[
      ['👂',AppText.get('tutorial1',widget.language)],
      ['🎙️',AppText.get('tutorial2',widget.language)],
      ['🤖',AppText.get('tutorial3',widget.language)],
    ];
    final last=step==items.length-1;
    return Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.all(24),child:Column(children:[
      const Spacer(),
      Text(items[step][0],style:const TextStyle(fontSize:80)),
      const SizedBox(height:28),
      Text(AppText.get('tutorial',widget.language),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w900),textAlign:TextAlign.center),
      const SizedBox(height:18),
      Text(items[step][1],style:const TextStyle(fontSize:18,color:AppColors.muted,height:1.45),textAlign:TextAlign.center),
      const Spacer(),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(items.length,(i)=>Container(width:8,height:8,margin:const EdgeInsets.all(4),decoration:BoxDecoration(color:i==step?AppColors.teal:AppColors.muted,borderRadius:BorderRadius.circular(8))))),
      const SizedBox(height:20),
      SizedBox(width:double.infinity,child:FilledButton(
        onPressed:()=>last?Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const MainNavigationScreen())):setState(()=>step++),
        child:Text(last?AppText.get('start',widget.language):AppText.get('continue',widget.language)))),
    ]))));
  }
}
