import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AishaHero extends StatelessWidget {
  final double scale;
  const AishaHero({super.key,this.scale=1});
  @override Widget build(BuildContext context)=>SizedBox(width:220*scale,height:300*scale,child:Stack(
    alignment:Alignment.topCenter,children:[
      Positioned(top:16*scale,left:27*scale,right:27*scale,child:Container(height:185*scale,decoration:BoxDecoration(color:const Color(0xFF5A2D3C),borderRadius:BorderRadius.circular(100*scale)))),
      Positioned(top:35*scale,child:Container(width:155*scale,height:155*scale,decoration:const BoxDecoration(shape:BoxShape.circle,gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFFFFD7C2),Color(0xFFEFB49D)])),child:Stack(children:[
        Positioned(left:35*scale,top:62*scale,child:_eye(scale)),Positioned(right:35*scale,top:62*scale,child:_eye(scale)),
        Positioned(left:63*scale,top:92*scale,child:Container(width:28*scale,height:14*scale,decoration:BoxDecoration(border:Border(bottom:BorderSide(color:const Color(0xFF9A4D58),width:3*scale)),borderRadius:BorderRadius.circular(20)))),
      ]))),
      Positioned(top:17*scale,left:41*scale,child:Container(width:138*scale,height:50*scale,decoration:BoxDecoration(color:const Color(0xFF5A2D3C),borderRadius:BorderRadius.only(topLeft:Radius.circular(70*scale),topRight:Radius.circular(70*scale),bottomRight:Radius.circular(28*scale),bottomLeft:Radius.circular(28*scale))))),
      Positioned(top:175*scale,child:Container(width:190*scale,height:125*scale,decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.teal,Color(0xFF0A6663)]),borderRadius:const BorderRadius.only(topLeft:Radius.circular(70),topRight:Radius.circular(70),bottomLeft:Radius.circular(30),bottomRight:Radius.circular(30))),child:Center(child:Text('A',style:TextStyle(color:Colors.white.withValues(alpha:.9),fontSize:58*scale,fontWeight:FontWeight.w900))))),
      Positioned(top:160*scale,child:Container(width:70*scale,height:38*scale,decoration:BoxDecoration(color:const Color(0xFFFFD7C2),borderRadius:BorderRadius.circular(20)))),
    ]));
  Widget _eye(double s)=>Container(width:14*s,height:14*s,decoration:const BoxDecoration(color:Color(0xFF35212A),shape:BoxShape.circle));
}