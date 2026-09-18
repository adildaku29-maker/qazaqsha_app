import 'package:flutter/material.dart';

import 'lesson_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      ('🏡', 'Үй', 'Дом'),
      ('🍽️', 'Дастархан', 'За столом'),
      ('👨‍👩‍👧', 'Адамдар', 'Люди'),
      ('🏙️', 'Қала', 'Город'),
      ('💼', 'Жұмыс', 'Работа'),
      ('✈️', 'Саяхат', 'Путешествия'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Оқу жолы',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: lessons.length,

        itemBuilder: (context, index) {
          final lesson = lessons[index];

          return GestureDetector(
            onTap: index == 0
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LessonScreen()),
                    );
                  }
                : null,

            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: index == 0 ? Colors.white : const Color(0xFFEDEFEF),

                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: index == 0
                      ? const Color(0xFF0F766E)
                      : const Color(0xFFE5E7EB),
                ),
              ),

              child: Row(
                children: [
                  Text(lesson.$1, style: const TextStyle(fontSize: 38)),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          lesson.$2,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          lesson.$3,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    index == 0 ? Icons.play_circle_fill : Icons.lock_outline,
                    color: index == 0
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF9CA3AF),
                    size: 30,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
