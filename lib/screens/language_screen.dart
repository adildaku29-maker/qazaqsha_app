import 'package:flutter/material.dart';

import 'character_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String language = 'ru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'На каком языке\nвам давать подсказки?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Қазақ тілі — основной язык обучения.\n'
              'Выберите язык переводов и объяснений.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            _languageCard(
              flag: '🇷🇺',
              title: 'Русский',
              subtitle: 'Переводы и объяснения на русском',
              value: 'ru',
            ),

            const SizedBox(height: 14),

            _languageCard(
              flag: '🇬🇧',
              title: 'English',
              subtitle: 'Translations and explanations in English',
              value: 'en',
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CharacterScreen(hintLanguage: language),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Продолжить',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageCard({
    required String flag,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final selected = language == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          language = value;
        });
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: selected ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),

        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 34)),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF0F766E)
                  : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
