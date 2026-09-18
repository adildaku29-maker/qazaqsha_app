import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../widgets/character.dart';
import 'lessons_screen.dart';
import 'hero_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final Player player;
  const HomeScreen({super.key, required this.player});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Player player;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  Future<void> refreshPlayer() async {
    final p = await StorageService.loadPlayer();
    if (p != null && mounted) setState(() => player = p);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      LessonsScreen(),
      HeroScreen(player: player),
      AchievementsScreen(player: player),
      ProfileScreen(player: player),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) async {
          await refreshPlayer();
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Обучение'),
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Герой'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Ачивки'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  Widget _home() {
    final nextXp = 100;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPlayer,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Сәлем, ${player.nickname}! 👋', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
                        const Text('Привет!', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  const Icon(Icons.settings_outlined),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF155E75)]),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  children: [
                    CharacterWidget(player: player, size: 88),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _whiteDual(rankName(player.level), rankRu(player.level), 13, 10),
                          const SizedBox(height: 5),
                          _whiteDual('${player.level} деңгей', 'Уровень ${player.level}', 21, 10),
                          const SizedBox(height: 9),
                          LinearProgressIndicator(
                            value: player.xp / nextXp,
                            minHeight: 7,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 5),
                          Text('${player.xp} / $nextXp XP', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('🔥 ${player.streak}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 27),
              _dual('Жалғастырайық!', 'Продолжим!', 23),
              const SizedBox(height: 14),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonsScreen())),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Text('🏡', style: TextStyle(fontSize: 34)),
                        SizedBox(width: 12),
                        Expanded(child: Text('Үй', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
                        Text('Дом', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      ]),
                      const Text('Алғашқы сөздер', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                      const Text('Первые слова', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                      const SizedBox(height: 14),
                      SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonsScreen())),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
                        child: const Text('Сабақты бастау  →\nНачать урок', textAlign: TextAlign.center),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _dual('Статистика', 'Статистика', 21),
              const SizedBox(height: 12),
              Row(children: [
                _stat('⭐', '${player.xp}', 'XP'),
                _stat('📚', '${player.completedLessons.length}', 'Сөз / уроков'),
                _stat('🔥', '${player.streak}', 'Күн / дней'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String icon, String value, String title) => Expanded(
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 23)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      ]),
    ),
  );

  Widget _dual(String kz, String ru, double size) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(kz, style: TextStyle(fontSize: size, fontWeight: FontWeight.w800)),
      Text(ru, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
    ],
  );

  Widget _whiteDual(String kz, String ru, double big, double small) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(kz, style: TextStyle(color: Colors.white70, fontSize: big, fontWeight: FontWeight.w700)),
      Text(ru, style: TextStyle(color: Colors.white54, fontSize: small)),
    ],
  );

  String rankName(int level) => ['Бала', 'Жас өрен', 'Сарбаз', 'Батыр', 'Сардар', 'Хан'][((level - 1).clamp(0, 5))];
  String rankRu(int level) => ['Ребёнок', 'Юный', 'Воин', 'Герой', 'Сардар', 'Хан'][((level - 1).clamp(0, 5))];
}
