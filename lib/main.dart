import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
void main(){WidgetsFlutterBinding.ensureInitialized();runApp(const QazaqshaApp());}
class QazaqshaApp extends StatelessWidget{const QazaqshaApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Qazaqsha',theme:AppTheme.dark(),home:const MainNavigationScreen());}
