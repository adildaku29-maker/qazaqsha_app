import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_profile_service.dart';
import 'main_navigation_screen.dart';

class AccountScreen extends StatefulWidget{
  final String language; final String goal;
  const AccountScreen({super.key,required this.language,required this.goal});
  @override State<AccountScreen> createState()=>_AccountScreenState();
}
class _AccountScreenState extends State<AccountScreen>{
  final age=TextEditingController(); final nickname=TextEditingController(); bool saving=false;
  @override void dispose(){age.dispose();nickname.dispose();super.dispose();}
  Future<void> _create()async{
    if(nickname.text.trim().isEmpty||int.tryParse(age.text.trim())==null)return;
    setState(()=>saving=true);
    await UserProfileService().save(nickname:nickname.text,language:widget.language,character:'🦅',goal:widget.goal,age:int.parse(age.text.trim()));
    if(!mounted)return;
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>const MainNavigationScreen()),(_)=>false);
  }
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(24,24,24,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Text('QAZAQSHA',style:TextStyle(color:AppColors.gold,fontWeight:FontWeight.w900,letterSpacing:2)),
    const SizedBox(height:35),const Text('Создать аккаунт',style:TextStyle(fontSize:32,fontWeight:FontWeight.w900)),
    const SizedBox(height:10),const Text('Сохрани свой прогресс и начни свой путь в Qazaqsha.',style:TextStyle(color:AppColors.muted,fontSize:16,height:1.4)),
    const SizedBox(height:32),
    TextField(controller:age,keyboardType:TextInputType.number,maxLength:3,decoration:InputDecoration(labelText:'Ваш возраст',hintText:'Например, 25',filled:true,fillColor:AppColors.card,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
    const SizedBox(height:12),
    TextField(controller:nickname,maxLength:18,textInputAction:TextInputAction.done,decoration:InputDecoration(labelText:'Придумайте ник',hintText:'Например, Adil',filled:true,fillColor:AppColors.card,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
    const Spacer(),
    SizedBox(width:double.infinity,height:56,child:FilledButton(onPressed:saving?null:_create,child:Text(saving?'Сохраняем…':'Создать аккаунт',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800))))
  ])));
}
