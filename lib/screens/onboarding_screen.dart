import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_profile_service.dart';
import '../ui/app_text.dart';
import 'tutorial_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState()=>_OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller=PageController();
  final nickname=TextEditingController();
  String lang='ru',character='🦅';
  final chars=['🦅','🐺','🛡️','🏹','👑'];

  @override void dispose(){controller.dispose();nickname.dispose();super.dispose();}

  @override Widget build(BuildContext context)=>Scaffold(
    body:SafeArea(child:PageView(
      controller:controller,physics:const NeverScrollableScrollPhysics(),children:[
        _welcome(),_language(),_character(),_name(),
      ],
    )),
  );

  Widget _shell(String title,String sub,Widget child,VoidCallback next)=>Padding(
    padding:const EdgeInsets.fromLTRB(24,30,24,24),
    child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('QAZAQSHA',style:TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900,letterSpacing:2)),
      const SizedBox(height:28),Text(title,style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900)),
      const SizedBox(height:8),Text(sub,style:const TextStyle(color:AppColors.muted,fontSize:16)),
      const SizedBox(height:28),Expanded(child:child),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:next,child:Text(AppText.get('continue',lang)))),
    ]),
  );

  Widget _welcome()=>_shell(
    'Сәлем! 👋','Qazaqsha арқылы қазақ тілін нөлден үйрен.',
    const Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Text('🇰🇿',style:TextStyle(fontSize:90)),SizedBox(height:18),
      Text('Қазақша сөйлеуді\nоңай бастаймыз.',textAlign:TextAlign.center,style:TextStyle(fontSize:25,fontWeight:FontWeight.w800)),
    ])),()=>controller.nextPage(duration:const Duration(milliseconds:280),curve:Curves.easeOut));

  Widget _language()=>_shell(
    AppText.get('choose_language',lang),
    'Қазақ тілі — негізгі оқу тілі. Әр жаңа фразаның төменінде түсіндірме болады.',
    Column(children:[_langTile('ru','🇷🇺','Русский'),_langTile('en','🇬🇧','English'),_langTile('kk','🇰🇿','Қазақша')]),
    ()=>controller.nextPage(duration:const Duration(milliseconds:280),curve:Curves.easeOut));

  Widget _langTile(String id,String icon,String title)=>ListTile(
    onTap:()=>setState(()=>lang=id),selected:lang==id,selectedTileColor:AppColors.card,
    shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),
    leading:Text(icon,style:const TextStyle(fontSize:28)),title:Text(title),
    trailing:lang==id?const Icon(Icons.check_circle,color:AppColors.teal):null);

  Widget _character()=>_shell(
    AppText.get('character',lang),
    'Бұл кейіпкер сенің оқу жолыңда деңгейлермен бірге өседі.',
    GridView.count(crossAxisCount:3,mainAxisSpacing:12,crossAxisSpacing:12,children:chars.map((x)=>InkWell(
      onTap:()=>setState(()=>character=x),borderRadius:BorderRadius.circular(24),
      child:Container(decoration:BoxDecoration(
        color:character==x?AppColors.teal.withValues(alpha:.18):AppColors.card,
        borderRadius:BorderRadius.circular(24),
        border:Border.all(color:character==x?AppColors.teal:Colors.transparent,width:2)),
        child:Center(child:Text(x,style:const TextStyle(fontSize:48)))))).toList()),
    ()=>controller.nextPage(duration:const Duration(milliseconds:280),curve:Curves.easeOut));

  Widget _name()=>_shell(
    AppText.get('nickname',lang),'Это будет твоё имя в приложении.',
    Column(children:[
      const SizedBox(height:40),
      TextField(controller:nickname,maxLength:18,textInputAction:TextInputAction.done,
        decoration:InputDecoration(labelText:'Nickname',hintText:'Например, Adil',filled:true,fillColor:AppColors.card,border:OutlineInputBorder(borderRadius:BorderRadius.circular(20),borderSide:BorderSide.none))),
      const SizedBox(height:18),
      Text('🇰🇿 Қазақ тілін үйренеміз!',style:TextStyle(color:AppColors.gold,fontWeight:FontWeight.w800)),
    ]),
    _finish);

  Future<void> _finish() async {
    if(nickname.text.trim().isEmpty)return;
    await UserProfileService().save(nickname:nickname.text,language:lang,character:character);
    if(!mounted)return;
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>TutorialScreen(language:lang)));
  }
}
