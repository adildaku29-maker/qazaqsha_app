import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/storage_service.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _selectedLang = 'ru';
  String _gender = 'male';
  int _skinColor = 0;
  final TextEditingController _nameController = TextEditingController(
    text: 'Алпамыс',
  );

  final List<Color> _skinColors = [
    const Color(0xFFFFD1AA),
    const Color(0xFFE5A075),
    const Color(0xFFB86B35),
  ];

  void _completeOnboarding() async {
    final player = Player(
      nickname: _nameController.text.trim().isEmpty
          ? 'Батыр'
          : _nameController.text.trim(),
      gender: _gender,
      skinColor: _skinColor,
      hintLanguage: _selectedLang,
    );
    await StorageService.savePlayer(player);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigationScreen(player: player)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_step == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🇰🇿 Qazaqsha',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF58CC02),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Выберите язык обучения / Choose app language:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          _langButton('Русский язык 🇷🇺', 'ru'),
          const SizedBox(height: 16),
          _langButton('English 🇬🇧', 'en'),
        ],
      );
    } else if (_step == 1) {
      final isRu = _selectedLang == 'ru';
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👦', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF58CC02), width: 2),
            ),
            child: Text(
              isRu
                  ? 'Сәлем! Я Алпамыс! Давай научимся казахскому языку вместе! Давай создадим твоего персонажа!'
                  : 'Sälem! I am Alpamys! Let us learn Kazakh together! Let us create your avatar!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => setState(() => _step = 2),
              child: Text(
                isRu ? 'Выбрать персонажа 🚀' : 'Create Avatar 🚀',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      final isRu = _selectedLang == 'ru';
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRu ? 'Создание персонажа' : 'Create Character',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: _skinColors[_skinColor],
                child: Text(
                  _gender == 'male' ? '👦' : '👧',
                  style: const TextStyle(fontSize: 50),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isRu ? 'Выберите пол:' : 'Select gender:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(isRu ? 'Мужчина ♂️' : 'Male ♂️'),
                    selected: _gender == 'male',
                    onSelected: (_) => setState(() => _gender = 'male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text(isRu ? 'Женщина ♀️' : 'Female ♀️'),
                    selected: _gender == 'female',
                    onSelected: (_) => setState(() => _gender = 'female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isRu ? 'Цвет кожи:' : 'Skin color:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (idx) => GestureDetector(
                  onTap: () => setState(() => _skinColor = idx),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _skinColors[idx],
                    child: _skinColor == idx
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: isRu ? 'Ваше имя / Никнейм' : 'Your name / Nickname',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _completeOnboarding,
                child: Text(
                  isRu
                      ? 'Начать изучать казахский язык 🇰🇿'
                      : 'Start Learning Kazakh 🇰🇿',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _langButton(String title, String code) {
    final isSel = _selectedLang == code;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(
          color: isSel ? const Color(0xFF58CC02) : Colors.grey.shade300,
          width: 2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        setState(() {
          _selectedLang = code;
          _step = 1;
        });
      },
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
