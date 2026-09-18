import 'package:flutter/material.dart';
import 'models/app_models.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final player = await StorageService.getPlayer();
  runApp(QazaqshaApp(initialPlayer: player));
}

class QazaqshaApp extends StatelessWidget {
  final Player? initialPlayer;
  const QazaqshaApp({super.key, this.initialPlayer});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Qazaqsha',
        theme: AppTheme.theme,
        home: initialPlayer == null
            ? const OnboardingScreen()
            : MainNavigationScreen(player: initialPlayer!),
      );
}
