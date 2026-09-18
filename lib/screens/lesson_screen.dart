import 'package:flutter/material.dart';

import 'lesson_result_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int question = 0;
  int correct = 0;

  final questions = [
    {
      'word': 'Үй',
      'answer': 'Дом',
      'options': ['Дом', 'Машина', 'Работа'],
    },
    {
      'word': 'Ана',
      'answer': 'Мама',
      'options': ['Папа', 'Мама', 'Друг'],
    },
    {
      'word': 'Әке',
      'answer': 'Папа',
      'options': ['Брат', 'Папа', 'Дом'],
    },
    {
      'word': 'Су',
      'answer': 'Вода',
      'options': ['Еда', 'Вода', 'Чай'],
    },
    {
      'word': 'Нан',
      'answer': 'Хлеб',
      'options': ['Мясо', 'Хлеб', 'Молоко'],
    },
  ];

  void answer(String value) {
    final current = questions[question];

    if (value == current['answer']) {
      correct++;
    }

    if (question == questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LessonResultScreen(correct: correct, total: questions.length),
        ),
      );
    } else {
      setState(() {
        question++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = questions[question];
    final options = current['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(title: Text('${question + 1}/${questions.length}')),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            LinearProgressIndicator(
              value: (question + 1) / questions.length,
              color: const Color(0xFF0F766E),
            ),

            const Spacer(),

            const Text(
              'Что означает это слово?',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            ),

            const SizedBox(height: 20),

            Text(
              current['word'] as String,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
            ),

            const Spacer(),

            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),

                child: SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: OutlinedButton(
                    onPressed: () => answer(option),

                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),

                    child: Text(option, style: const TextStyle(fontSize: 17)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
