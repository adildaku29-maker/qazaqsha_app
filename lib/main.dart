import 'package:flutter/material.dart';

import 'models/app_models.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final player = await StorageService.getPlayer();

  runApp(QazaqshaApp(initialPlayer: player));
}

class QazaqshaApp extends StatelessWidget {
  final Player? initialPlayer;
  const QazaqshaApp({super.key, this.initialPlayer});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qazaqsha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A896), // Казахский бирюзовый
          secondary: const Color(0xFFE5A93C), // Орнаментный золотой
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00A896),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: initialPlayer == null
          ? const OnboardingScreen()
          : MainNavigationScreen(player: initialPlayer!),
    );
  }
}
