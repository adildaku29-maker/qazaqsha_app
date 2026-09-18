import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const QazaqshaApp());
}

class QazaqshaApp extends StatelessWidget {
  const QazaqshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qazaqsha',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      home: const WelcomeScreen(),
    );
  }
}
