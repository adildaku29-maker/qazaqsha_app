import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  String language = 'ru';
  String gender = 'male';
  int skin = 0;
  final name = TextEditingController();
  final skins = [const Color(0xFFF5C7A9), const Color(0xFFD99569), const Color(0xFF8D5A3B)];

  @override void dispose() { name.dispose(); super.dispose(); }

  Future<void> finish() async {
    final p = Player(nickname: name.text.trim().isEmpty ? 'Батыр' : name.text.trim(), gender: gender, skinColor: skin, hintLanguage: language);
    await StorageService.savePlayer(p);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavigationScreen(player: p)));
  }

  @override Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 20), child: step == 0 ? _language() : _profile())));
  }

  Widget _language() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('🇰🇿 Qazaqsha', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: AppTheme.primary)),
    const SizedBox(height: 12), const Text('Қазақ тілін күн сайын аз-аздан үйрен.', style: TextStyle(fontSize: 18)),
    const Spacer(), const Text('Для подсказок какой язык вам удобнее?', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    const SizedBox(height: 18), _lang('🇷🇺  Русский', 'ru'), _lang('🇬🇧  English', 'en'), const Spacer(),
    const Text('Основной язык обучения — қазақ тілі 🇰🇿', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
  ]);

  Widget _lang(String text, String code) => Padding(padding: const EdgeInsets.only(bottom: 12), child: OutlinedButton(onPressed: () { setState(() { language = code; step = 1; }); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18), alignment: Alignment.centerLeft, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))));

  Widget _profile() => ListView(children: [
    IconButton(alignment: Alignment.centerLeft, onPressed: () => setState(() => step = 0), icon: const Icon(Icons.arrow_back)),
    const SizedBox(height: 8), const Text('Создай своего героя', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)), const SizedBox(height: 24),
    Center(child: CircleAvatar(radius: 58, backgroundColor: skins[skin].withOpacity(.45), child: Text(gender == 'female' ? '👧' : '👦', style: const TextStyle(fontSize: 64)))),
    const SizedBox(height: 22), const Text('Пол', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
    Row(children: [Expanded(child: ChoiceChip(label: const Text('♂️ Мужчина'), selected: gender == 'male', onSelected: (_) => setState(() => gender = 'male'))), const SizedBox(width: 10), Expanded(child: ChoiceChip(label: const Text('♀️ Женщина'), selected: gender == 'female', onSelected: (_) => setState(() => gender = 'female')))]),
    const SizedBox(height: 20), const Text('Внешность', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(3, (i) => GestureDetector(onTap: () => setState(() => skin = i), child: CircleAvatar(radius: 23, backgroundColor: skins[i], child: skin == i ? const Icon(Icons.check, color: Colors.white) : null)))),
    const SizedBox(height: 20), TextField(controller: name, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: 'Имя / никнейм', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
    const SizedBox(height: 24), SizedBox(height: 54, child: FilledButton(onPressed: finish, style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Начать обучение 🇰🇿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))
  ]);
}
