import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/storage_service.dart';
import '../widgets/character.dart';
import 'home_screen.dart';

class CharacterScreen extends StatefulWidget {
  final String hintLanguage;
  const CharacterScreen({super.key, required this.hintLanguage});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  String gender = 'male';
  int skin = 1;
  int hairStyle = 0;
  int hairColor = 0;
  int clothes = 0;
  int glasses = 0;
  final nicknameController = TextEditingController();

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  Player get preview => Player(
    nickname: nicknameController.text.trim().isEmpty ? 'Батыр' : nicknameController.text.trim(),
    hintLanguage: widget.hintLanguage,
    gender: gender,
    skinColor: skin,
    hairStyle: hairStyle,
    hairColor: hairColor,
    clothes: clothes,
    glasses: glasses,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Өз кейіпкеріңді жаса')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 25),
          child: Column(
            children: [
              const _DualText(big: 'Бұл сенің кейіпкерің', small: 'Это твой герой'),
              const SizedBox(height: 4),
              const Text(
                'Ол сенімен бірге дамиды',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F6F2), Color(0xFFF3F5FF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: CharacterWidget(player: preview, size: 155),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nicknameController,
                onChanged: (_) => setState(() {}),
                maxLength: 16,
                decoration: InputDecoration(
                  labelText: 'Никнейм',
                  hintText: 'Например: Аян',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              _section('Жыныс', 'Пол'),
              _choices([
                _Choice('👨', 'Ер', gender == 'male', () => setState(() => gender = 'male')),
                _Choice('👩', 'Әйел', gender == 'female', () => setState(() => gender = 'female')),
              ]),
              _section('Тері түсі', 'Цвет кожи'),
              _choices(List.generate(5, (i) => _colorChoice(
                CharacterWidget.skin[i], skin == i, () => setState(() => skin = i),
              ))),
              _section('Шаш үлгісі', 'Причёска'),
              _choices(List.generate(5, (i) => _Choice(
                ['◉', '◌', '◍', '✦', '✿'][i], 'Стиль ${i + 1}',
                hairStyle == i, () => setState(() => hairStyle = i),
              ))),
              _section('Шаш түсі', 'Цвет волос'),
              _choices(List.generate(5, (i) => _colorChoice(
                CharacterWidget.hair[i], hairColor == i, () => setState(() => hairColor = i),
              ))),
              _section('Киім', 'Одежда'),
              _choices(List.generate(7, (i) => _Choice(
                ['👕', '🧥', '🥋', '🦺', '🧣', '⚔️', '🏹'][i],
                ['Классика', 'Куртка', 'Дәстүрлі', 'Тактикалық', 'Саяхат', 'Батыр', 'Сарбаз'][i],
                clothes == i, () => setState(() => clothes = i),
              ))),
              _section('Көзілдірік', 'Очки'),
              _choices([
                _Choice('—', 'Жоқ', glasses == 0, () => setState(() => glasses = 0)),
                _Choice('👓', 'Классика', glasses == 1, () => setState(() => glasses = 1)),
                _Choice('🕶️', 'Қара', glasses == 2, () => setState(() => glasses = 2)),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final player = preview;
                    await StorageService.savePlayer(player);
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen(player: player)),
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Готово  →', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String kz, String ru) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kz, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          Text(ru, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    ),
  );

  Widget _choices(List<Widget> children) => Wrap(
    spacing: 9, runSpacing: 9, children: children,
  );

  Widget _colorChoice(Color color, bool selected, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF0F766E) : Colors.white,
          width: selected ? 4 : 2,
        ),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 5)],
      ),
      child: selected ? const Icon(Icons.check, color: Colors.white) : null,
    ),
  );
}

class _Choice extends StatelessWidget {
  final String icon, label;
  final bool selected;
  final VoidCallback onTap;

  const _Choice(this.icon, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE6F4F1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF0F766E) : const Color(0xFFE5E7EB),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 25)),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

class _DualText extends StatelessWidget {
  final String big, small;
  const _DualText({required this.big, required this.small});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(big, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      Text(small, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
    ],
  );
}
