import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'account_screen.dart';

class StreakScreen extends StatelessWidget {
  final String language;
  final String goal;
  const StreakScreen({super.key, required this.language, required this.goal});

  String tx(String ru, String en, String kk) => language == 'en' ? en : language == 'kk' ? kk : ru;

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: .28),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔥', style: TextStyle(fontSize: 68)),
                      Text('1', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.gold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(tx('День в ударе!', 'Day one is on fire!', 'Бірінші күн керемет басталды!'),
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(tx('Продолжай и дальше!', 'Keep it going!', 'Жалғастыра бер!'),
                style: const TextStyle(color: AppColors.muted, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 38),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AccountScreen(language: language, goal: goal)),
                  ),
                  child: Text(tx('Продолжить', 'Continue', 'Жалғастыру'),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
