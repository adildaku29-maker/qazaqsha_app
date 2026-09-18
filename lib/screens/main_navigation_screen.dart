import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/storage_service.dart';
import 'duo_lesson_screen.dart';
import 'onboarding_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Player player;
  const MainNavigationScreen({super.key, required this.player});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // По умолчанию вкладка "Главное" по центру

  void _refreshPlayer() async {
    final updated = await StorageService.getPlayer();
    if (updated != null) {
      setState(() => widget.player.xp = updated.xp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildLevelTab(), // Слева: Уровень и Герой
      _buildHomeTab(), // В центре: Главная (Уроки)
      _buildProfileTab(), // Справа: Профиль
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF58CC02),
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Деңгей (XP)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 32),
            label: 'Басты (Главная)',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  // 1. Вкладка Слева: Уровень Персонажа
  Widget _buildLevelTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            widget.player.rankTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF58CC02),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFF0FDF4),
            child: Text(
              widget.player.avatarEmoji,
              style: const TextStyle(fontSize: 70),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'XP: ${widget.player.xp} / 500+ XP',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (widget.player.xp % 500) / 500,
            minHeight: 12,
            color: const Color(0xFF58CC02),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Шкала эволюции героя:\n• 0 - 499 XP: Бала 👶\n• 500 - 1499 XP: Жігіт 🧑\n• 1500 - 2999 XP: Еркек 🧔\n• 3000+ XP: Батыр ⚔️',
              style: TextStyle(height: 1.6, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Вкладка В центре: Главное Дерево Уроков
  Widget _buildHomeTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF7F7F7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                '🔥 ${widget.player.streak}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '⚡ ${widget.player.xp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                '❤️ ${widget.player.hearts}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              final double offsetX = (index % 2 == 0) ? 40.0 : -40.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                        backgroundColor: const Color(0xFF58CC02),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DuoLessonScreen(player: widget.player),
                          ),
                        );
                        _refreshPlayer();
                      },
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Вкладка Справа: Профиль и Настройки
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.player.avatarEmoji,
                style: const TextStyle(fontSize: 50),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.player.nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Язык: ${widget.player.hintLanguage.toUpperCase()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          const Text(
            'Настройки',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text('Звуковые эффекты'),
            value: true,
            onChanged: (val) {},
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                await StorageService.clearPlayer();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  );
                }
              },
              child: const Text('Сбросить прогресс и персонажа'),
            ),
          ),
        ],
      ),
    );
  }
}
