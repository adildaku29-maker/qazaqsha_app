import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../widgets/ornament_container.dart';

class DuoLessonScreen extends StatefulWidget {
  final Player player;
  const DuoLessonScreen({super.key, required this.player});

  @override
  State<DuoLessonScreen> createState() => _DuoLessonScreenState();
}

class _DuoLessonScreenState extends State<DuoLessonScreen> {
  bool _showingIntro = true;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _hearts = 5;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechInitialized = false;
  bool _isInitializing = false;
  String _spokenText = "Микрофонды басып, сөйлеңіз...";
  List<String> _selectedWords = [];

  final List<Question> _questions = [
    Question(
      id: '1',
      type: QuestionType.choice,
      questionText: 'Асханада: «Нан» деген не?',
      questionTranslation: 'В столовой: Что значит «Нан»?',
      correctAnswer: 'Хлеб',
      options: ['Хлеб', 'Вода', 'Соль', 'Мясо'],
    ),
    Question(
      id: '2',
      type: QuestionType.choice,
      questionText: '«Су әкеліңізші» аудармасы:',
      questionTranslation: 'Перевод: «Принесите воду, пожалуйста»',
      correctAnswer: 'Принесите воду',
      options: ['Принесите воду', 'Дайте счет', 'Всe вкусно', 'Спасибо'],
    ),
    Question(
      id: '3',
      type: QuestionType.speaking,
      questionText: 'Микрофонға айтыңыз: «Рақмет»',
      questionTranslation: 'Скажите в микрофон: «Спасибо»',
      correctAnswer: 'рақмет',
    ),
    Question(
      id: '4',
      type: QuestionType.assemble,
      questionText: 'Сөйлемді құрастырыңыз: «Я ем мясо»',
      questionTranslation: 'Соберите предложение: «Я ем мясо»',
      correctAnswer: 'Мен ет жеймін',
      options: ['Мен', 'ет', 'жеймін', 'су', 'ішемін'],
    ),
    Question(
      id: '5',
      type: QuestionType.choice,
      questionText: '«Шай ішесіз бе?» деген не?',
      questionTranslation: 'Что значит «Будете чай?»',
      correctAnswer: 'Будете чай?',
      options: ['Будете чай?', 'Где туалет?', 'Сколько стоит?', 'Пока'],
    ),
    Question(
      id: '6',
      type: QuestionType.choice,
      questionText: 'Үйде: «Төрлетіңіз» деген сөз:',
      questionTranslation: 'Дома: слово «Проходите на почетное место»:',
      correctAnswer: 'Проходите в дом',
      options: [
        'Проходите в дом',
        'До свидания',
        'Закройте дверь',
        'Спокойной ночи',
      ],
    ),
    Question(
      id: '7',
      type: QuestionType.speaking,
      questionText: 'Айтыңыз: «Сәлеметсіз бе»',
      questionTranslation: 'Скажите: «Здравствуйте»',
      correctAnswer: 'сәлеметсіз бе',
    ),
    Question(
      id: '8',
      type: QuestionType.assemble,
      questionText: 'Құрастырыңыз: «Приятного аппетита»',
      questionTranslation: 'Соберите: «Приятного аппетита»',
      correctAnswer: 'Асыңыз дәмді болсын',
      options: ['Асыңыз', 'дәмді', 'болсын', 'нан', 'су'],
    ),
    Question(
      id: '9',
      type: QuestionType.choice,
      questionText: '«Қанша тұрады?» аудармасы:',
      questionTranslation: 'Перевод фразы «Сколько стоит?»:',
      correctAnswer: 'Сколько стоит?',
      options: ['Сколько стоит?', 'Как дела?', 'Который час?', 'Где магазин?'],
    ),
    Question(
      id: '10',
      type: QuestionType.choice,
      questionText: '«Өте дәмді!» деген не?',
      questionTranslation: 'Что значит «Очень вкусно!»?',
      correctAnswer: 'Очень вкусно!',
      options: ['Очень вкусно!', 'Плохо', 'Горячо', 'Холодно'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    if (_isInitializing || _speechInitialized) return;
    _isInitializing = true;
    try {
      bool available = await _speech.initialize(
        onError: (val) => print('Error: $val'),
        onStatus: (val) => print('Status: $val'),
      );
      if (mounted) {
        setState(() {
          _speechInitialized = available;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _listen() async {
    if (_isInitializing) return;
    if (!_speechInitialized) {
      await _speech.initialize();
      _speechInitialized = true;
    }

    if (!_isListening) {
      if (_speechInitialized) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'kk_KZ',
          onResult: (val) {
            setState(() {
              _spokenText = val.recognizedWords;
              if (_spokenText.toLowerCase().contains(
                _questions[_currentIndex].correctAnswer.toLowerCase(),
              )) {
                _answer(true);
              }
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Микрофонға рұқсат берілмеді')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _answer(bool isCorrect) async {
    if (isCorrect) {
      _correctCount++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дұрыс! (Верно) 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 800),
        ),
      );
    } else {
      _hearts--;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Қате! (Ошибка) ❌'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 800),
        ),
      );
    }

    if (_hearts <= 0) {
      _finishLesson(passed: false);
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedWords.clear();
        _spokenText = "Микрофонды басып, сөйлеңіз...";
        _isListening = false;
      });
    } else {
      _finishLesson(passed: _correctCount >= 7);
    }
  }

  void _finishLesson({required bool passed}) async {
    if (passed) {
      widget.player.xp += 100;
      widget.player.completedLessonsCount++;
      await StorageService.savePlayer(widget.player);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(passed ? 'Сабақ аяқталды! 🏆' : 'Сәтсіз өтті 💔'),
        content: Text(
          passed
              ? 'Cіз 10-нан $_correctCount дұрыс жауап бердіңіз!\n+100 XP жинадыңыз!'
              : 'Вы ответили верно на $_correctCount из 10. Попробуйте еще раз!',
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

  @override
  Widget build(BuildContext context) {
    if (_showingIntro) {
      return Scaffold(
        appBar: AppBar(title: const Text('Краткое обучение 📚')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OrnamentContainer(
                child: Column(
                  children: const [
                    Text(
                      '🍽️ Ресторан және Тамақ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      '💡 Полный словарь урока:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '• Нан — Хлеб\n'
                      '• Су — Вода\n'
                      '• Рақмет — Спасибо\n'
                      '• Асыңыз дәмді болсын — Приятного аппетита\n'
                      '• Мен ет жеймін — Я ем мясо\n'
                      '• Шай ішесіз бе? — Будете чай?\n'
                      '• Төрлетіңіз — Проходите в дом\n'
                      '• Сәлеметсіз бе — Здравствуйте\n'
                      '• Қанша тұрады? — Сколько стоит?\n'
                      '• Өте дәмді — Очень вкусно',
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                  ),
                  onPressed: () => setState(() => _showingIntro = false),
                  child: const Text(
                    'Начать тест (10 вопросов) 📝',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Вопрос ${_currentIndex + 1}/10'),
        actions: [
          Center(
            child: Text(
              '❤️ $_hearts  ',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildQuestionHeader(q),
            const Spacer(),
            _buildQuestionBody(q),
            const Spacer(),
            if (q.type == QuestionType.assemble)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                  ),
                  onPressed: () =>
                      _answer(_selectedWords.join(' ') == q.correctAnswer),
                  child: const Text(
                    'ПРОВЕРИТЬ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(Question q) {
    return Column(
      children: [
        Text(
          q.questionText,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (q.questionTranslation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF58CC02).withOpacity(0.5),
              ),
            ),
            child: Text(
              '💡 Аудармасы: ${q.questionTranslation}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionBody(Question q) {
    if (q.type == QuestionType.choice) {
      return Column(
        children: q.options
            .map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE5A93C),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => _answer(opt == q.correctAnswer),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
    } else if (q.type == QuestionType.speaking) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              _spokenText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: _isListening ? Colors.red : Colors.black87,
                fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _listen,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(_isListening ? 8 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Colors.red.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: CircleAvatar(
                radius: 44,
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
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5A93C), width: 1.5),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedWords
                  .map(
                    (w) => Chip(
                      backgroundColor: const Color(0xFFE8F5E9),
                      side: const BorderSide(color: Color(0xFF58CC02)),
                      label: Text(
                        w,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onDeleted: () => setState(() => _selectedWords.remove(w)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: q.options.map((w) {
              final sel = _selectedWords.contains(w);
              return ActionChip(
                elevation: sel ? 0 : 2,
                backgroundColor: sel ? Colors.grey.shade200 : Colors.white,
                side: BorderSide(
                  color: sel ? Colors.transparent : const Color(0xFF1CB0F6),
                ),
                label: Text(
                  w,
                  style: TextStyle(
                    color: sel ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: sel
                    ? null
                    : () => setState(() => _selectedWords.add(w)),
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
