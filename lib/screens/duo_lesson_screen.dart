import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import '../models/duo_models.dart';

class DuoLessonScreen extends StatefulWidget {
  const DuoLessonScreen({super.key});

  @override
  State<DuoLessonScreen> createState() => _DuoLessonScreenState();
}

class _DuoLessonScreenState extends State<DuoLessonScreen> {
  int hearts = 5;
  int currentIndex = 0;
  double progress = 0.2;

  // Логика микрофона
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "Нажмите на микрофон и говорите...";

  // Логика конструктора фраз (Assemble)
  List<String> selectedWords = [];

  // Список вопросов интерактивного урока "Qazaqsha"
  final List<DuoQuestion> questions = [
    DuoQuestion(
      id: '1',
      type: QuestionType.translate,
      questionText: 'Сәлем! Қалың қалай?',
      correctAnswer: 'Привет! Как дела?',
      options: ['Привет! Как дела?', 'Доброе утро', 'До свидания', 'Спасибо'],
    ),
    DuoQuestion(
      id: '2',
      type: QuestionType.speaking,
      questionText: 'Қайырлы таң',
      correctAnswer: 'қайырлы таң',
    ),
    DuoQuestion(
      id: '3',
      type: QuestionType.assemble,
      questionText: 'Переведите: «Мен алма жеймін»',
      correctAnswer: 'Я ем яблоко',
      options: ['Я', 'ем', 'банан', 'яблоко', 'ты', 'вода'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _spokenText = val.recognizedWords;
            if (_spokenText.toLowerCase().contains(
              questions[currentIndex].correctAnswer.toLowerCase(),
            )) {
              _nextQuestion(true);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _nextQuestion(bool isCorrect) {
    if (!isCorrect) {
      setState(() => hearts--);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Кате! (Ошибка) ❌'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Өте жақсы! (Отлично!) 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (hearts <= 0) {
      _showGameOver();
      return;
    }

    setState(() {
      if (currentIndex < questions.length - 1) {
        currentIndex++;
        progress = (currentIndex + 1) / questions.length;
        selectedWords.clear();
        _spokenText = "Нажмите на микрофон и говорите...";
        _isListening = false;
      } else {
        _showSuccess();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Жүректер таусылды 💔'),
        content: const Text(
          'У вас закончились жизни. Попробуйте пройти урок снова!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Жарайсың! 🏆'),
        content: const Text('Вы успешно прошли урок в Qazaqsha! +15 XP'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Қабылдау (Продолжить)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF58CC02),
                  ), // Зеленый Duolingo
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.favorite, color: Colors.red, size: 28),
            const SizedBox(width: 4),
            Text(
              '$hearts',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getInstructionText(currentQ.type),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B4B4B),
                ),
              ),
              const SizedBox(height: 24),

              // Диалоговое облачко с маскотом
              Row(
                children: [
                  const Text(
                    '🦉',
                    style: TextStyle(fontSize: 54),
                  ), // Маскот Qazaqsha
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        currentQ.questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Виджет под тип вопроса
              Expanded(child: _buildQuestionContent(currentQ)),

              // Кнопка проверки
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentQ.type == QuestionType.assemble) {
                      _nextQuestion(
                        selectedWords.join(' ') == currentQ.correctAnswer,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'ТЕКСЕРУ (ПРОВЕРИТЬ)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInstructionText(QuestionType type) {
    switch (type) {
      case QuestionType.translate:
        return 'Выберите правильный перевод:';
      case QuestionType.speaking:
        return 'Произнесите фразу на казахском:';
      case QuestionType.assemble:
        return 'Соберите предложение:';
    }
  }

  Widget _buildQuestionContent(DuoQuestion q) {
    switch (q.type) {
      case QuestionType.translate:
        return ListView(
          children: q.options
              .map(
                (opt) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _nextQuestion(opt == q.correctAnswer),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black80,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );

      case QuestionType.speaking:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _spokenText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _listen,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isListening
                    ? Colors.red
                    : const Color(0xFF1CB0F6),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        );

      case QuestionType.assemble:
        return Column(
          children: [
            // Зона собранных слов
            Container(
              minHeight: 60,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                ),
              ),
              child: Wrap(
                spacing: 8,
                children: selectedWords
                    .map(
                      (w) => Chip(
                        label: Text(w),
                        onDeleted: () =>
                            setState(() => selectedWords.remove(w)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Варианты слов
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: q.options.map((w) {
                final isSelected = selectedWords.contains(w);
                return ActionChip(
                  label: Text(
                    w,
                    style: TextStyle(
                      color: isSelected ? Colors.transparent : Colors.black,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? const Color(0xFFE5E7EB)
                      : Colors.white,
                  onPressed: isSelected
                      ? null
                      : () => setState(() => selectedWords.add(w)),
                );
              }).toList(),
            ),
          ],
        );
    }
  }
}
