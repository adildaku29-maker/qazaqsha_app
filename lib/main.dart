import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/user_profile_service.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QazaqshaApp());
}

class QazaqshaApp extends StatelessWidget {
  const QazaqshaApp({super.key});
  @override Widget build(BuildContext context)=>MaterialApp(
    debugShowCheckedModeBanner:false,
    title:'Qazaqsha',
    theme:AppTheme.dark(),
    home:const _Startup(),
  );
}

class _Startup extends StatelessWidget {
  const _Startup();
  @override Widget build(BuildContext context)=>FutureBuilder<bool>(
    future:UserProfileService().isRegistered,
    builder:(context,snapshot){
      if(!snapshot.hasData)return const Scaffold(body:Center(child:CircularProgressIndicator()));
      return snapshot.data!?const MainNavigationScreen():const OnboardingScreen();
    },
  );
}
