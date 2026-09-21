import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/storage_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';

class DuoLessonScreen extends StatefulWidget {
  final Player player;
  final Lesson lesson;
  const DuoLessonScreen({super.key, required this.player, required this.lesson});
  @override State<DuoLessonScreen> createState() => _DuoLessonScreenState();
}

class _DuoLessonScreenState extends State<DuoLessonScreen> {
  final SpeechService speech = SpeechService();
  final typing = TextEditingController();
  final assembled = <String>[];
  int phase = 0; // 0 learning, 1 practice, 2 speaking, 3 result
  int q = 0;
  int correct = 0;
  bool answered = false;
  bool listening = false;
  String transcript = '';
  Timer? _amplitudeTimer;
  DateTime? _recordingStartedAt;
  DateTime? _lastSpeechAt;
  bool _checkingAmplitude = false;
  String? selected;

  Question get question => widget.lesson.questions[q];
  List<MapEntry<String, String>> get vocabulary => widget.lesson.vocabulary;
  int get speechCount => min(2, vocabulary.length);

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    speech.cancel();
    typing.dispose();
    super.dispose();
  }

  String norm(String s) => s.toLowerCase().trim()
      .replaceAll(RegExp(r'[.!?,]'), '')
      .replaceAll(RegExp(r'ә'), 'а')
      .replaceAll(RegExp(r'і'), 'и')
      .replaceAll(RegExp(r'ө'), 'о')
      .replaceAll(RegExp(r'ү'), 'у')
      .replaceAll(RegExp(r'ұ'), 'у')
      .replaceAll(RegExp(r'қ'), 'к')
      .replaceAll(RegExp(r'ғ'), 'г')
      .replaceAll(RegExp(r'ң'), 'н')
      .replaceAll(RegExp(r'һ'), 'х')
      .replaceAll(RegExp(r'ъ|ь'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  void answer(String value) {
    if (answered) return;
    final ok = norm(value) == norm(question.correctAnswer);
    setState(() { answered = true; selected = value; if (ok) correct++; });
  }

  void assembleWord(String value) {
    if (answered) return;
    setState(() {
      if (assembled.contains(value)) assembled.remove(value); else assembled.add(value);
    });
  }

  void checkAssemble() => answer(assembled.join(' '));

  Future<void> nextPractice() async {
    if (!answered) return;
    if (q < widget.lesson.questions.length - 1) {
      setState(() { q++; answered = false; selected = null; typing.clear(); assembled.clear(); });
    } else {
      setState(() { phase = 2; q = 0; answered = false; transcript = ''; });
    }
  }

  Future<void> startListening() async {
    if (listening) {
      await _stopListeningAndTranscribe();
      return;
    }

    setState(() {
      listening = true;
      transcript = '';
    });

    _recordingStartedAt = DateTime.now();
    _lastSpeechAt = DateTime.now();
    _amplitudeTimer?.cancel();
    _checkingAmplitude = false;

    final ok = await speech.listen();
    if (!ok) {
      if (mounted) setState(() => listening = false);
      return;
    }

    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) async {
        if (!listening || _checkingAmplitude) return;

        _checkingAmplitude = true;
        try {
          final amplitude = await speech.getRecorderAmplitude();

          final started = _recordingStartedAt;
          if (started == null || !listening) return;

          final elapsed = DateTime.now().difference(started);

          // Даём пользователю 700 мс на начало речи.
          if (elapsed < const Duration(milliseconds: 700)) {
            return;
          }

          final isSpeaking = amplitude > -42.0;

          if (isSpeaking) {
            _lastSpeechAt = DateTime.now();
          } else {
            final lastSpeech = _lastSpeechAt ?? started;
            final silenceDuration =
                DateTime.now().difference(lastSpeech);

            // 1 секунда тишины после последнего звука.
            if (silenceDuration >= const Duration(milliseconds: 1000)) {
              await _stopListeningAndTranscribe();
            }
          }
        } catch (e) {
          print('[QAZAQSHA][MIC] amplitude error: $e');
        } finally {
          _checkingAmplitude = false;
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _stopListeningAndTranscribe() async {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _recordingStartedAt = null;
    _lastSpeechAt = null;

    if (!listening) return;

    if (mounted) {
      setState(() => listening = false);
    }

    try {
      final text = await speech.stop();
      if (!mounted) return;

      setState(() {
        transcript = text?.trim() ?? '';
      });

      if (transcript.trim().isNotEmpty) {
        checkSpeech();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => listening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка распознавания: $e')),
      );
    }
  }

  void checkSpeech() {
    if (transcript.trim().isEmpty) return;
    final target = vocabulary[q].key;
    final ok = norm(transcript) == norm(target) ||
        norm(transcript).contains(norm(target)) ||
        norm(target).contains(norm(transcript));
    setState(() { answered = true; if (ok) correct++; });
  }

  Future<void> nextSpeech() async {
    if (!answered) return;
    if (q < speechCount - 1) {
      setState(() { q++; answered = false; transcript = ''; });
    } else {
      await finishLesson();
    }
  }

  Future<void> finishLesson() async {
    final firstTime = !widget.player.isCompleted(widget.lesson.id);
    final total = widget.lesson.questions.length + speechCount;
    final gained = 20 + correct * 10;
    if (firstTime) {
      widget.player.xp += gained;
      widget.player.completedLessons = [...widget.player.completedLessons, widget.lesson.id]..sort();
      widget.player.completedLessonsCount = widget.player.completedLessons.length;
    }
    await StorageService.savePlayer(widget.player);
    if (mounted) setState(() => phase = 3);
  }

  @override
  Widget build(BuildContext context) {
    if (phase == 0) return _learning();
    if (phase == 3) return _result();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lesson.icon} ${phase == 1 ? 'Практика' : 'Говорение'}'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text(
          phase == 1 ? '${q + 1}/${widget.lesson.questions.length}' : '${q + 1}/$speechCount',
          style: const TextStyle(fontWeight: FontWeight.bold),
        )))],
      ),
      body: Column(children: [
        LinearProgressIndicator(value: phase == 1 ? (q + (answered ? 1 : 0)) / widget.lesson.questions.length : (q + (answered ? 1 : 0)) / speechCount, minHeight: 5),
        Expanded(child: ListView(padding: const EdgeInsets.all(18), children: [
          if (phase == 1) ...[_questionHeader(), const SizedBox(height: 18), _questionBody(), if (answered) Padding(padding: const EdgeInsets.only(top: 18), child: _feedback())]
          else ...[_speechHeader(), const SizedBox(height: 24), _speechBody()],
        ])),
        if (phase == 1) _bottom(onPressed: answered ? nextPractice : null, label: q == widget.lesson.questions.length - 1 ? 'Перейти к говорению' : 'Продолжить')
        else _bottom(onPressed: answered ? nextSpeech : null, label: q == speechCount - 1 ? 'Завершить урок' : 'Следующее'),
      ]),
    );
  }

  Widget _learning() => Scaffold(
    appBar: AppBar(title: Text('${widget.lesson.icon} ${widget.lesson.title}')),
    body: Column(children: [
      LinearProgressIndicator(value: 0.15, minHeight: 5),
      Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 20, 18, 30), children: [
        Text('Сначала изучим материал', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Запомни слова и фразы. Они встретятся в практике и заданиях с микрофоном.', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
        const SizedBox(height: 20),
        ...vocabulary.asMap().entries.map((entry) => _vocabCard(entry.key + 1, entry.value.key, entry.value.value)),
        const SizedBox(height: 12),
        Card(color: AppTheme.primary.withOpacity(.08), child: const Padding(padding: EdgeInsets.all(16), child: Row(children: [Icon(Icons.mic, size: 30), SizedBox(width: 12), Expanded(child: Text('После обучения ты произнесёшь слова вслух. Приложение распознает казахскую речь через микрофон.'))]))),
      ])),
      _bottom(onPressed: () => setState(() => phase = 1), label: 'Начать практику'),
    ],),
  );

  Widget _vocabCard(int number, String kz, String ru) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
      CircleAvatar(radius: 18, child: Text('$number')),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kz, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(ru, style: const TextStyle(color: Colors.grey))])),
      const Icon(Icons.volume_up_outlined, color: AppTheme.primary),
    ])),
  );

  Widget _questionHeader() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(question.questionText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(question.translation, style: const TextStyle(color: Colors.grey, fontSize: 16))]);

  Widget _questionBody() {
    switch (question.type) {
      case QuestionType.choice:
        return Column(children: question.options.map((o) { final isSel = selected == o; final isCorrect = norm(o) == norm(question.correctAnswer); return Padding(padding: const EdgeInsets.only(bottom: 10), child: _answerButton(o, isSel, answered && isCorrect)); }).toList());
      case QuestionType.assemble:
        return Column(children: [Wrap(spacing: 8, runSpacing: 8, children: assembled.map((x) => Chip(label: Text(x))).toList()), const SizedBox(height: 18), Wrap(spacing: 8, runSpacing: 10, children: question.options.map((o) => OutlinedButton(onPressed: answered ? null : () => assembleWord(o), child: Text(o))).toList()), const SizedBox(height: 18), SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: answered || assembled.isEmpty ? null : checkAssemble, child: const Text('Проверить')))]);
      case QuestionType.typing:
        return Column(children: [TextField(controller: typing, enabled: !answered, textInputAction: TextInputAction.done, onSubmitted: (_) => answer(typing.text), decoration: InputDecoration(hintText: 'Введите на казахском', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))), const SizedBox(height: 12), SizedBox(width: double.infinity, height: 50, child: FilledButton(onPressed: answered ? null : () => answer(typing.text), child: const Text('Проверить')))]);
    }
  }

  Widget _answerButton(String text, bool selectedHere, bool correctHere) { Color? bg; if (answered && correctHere) bg = Colors.green.withOpacity(.15); else if (answered && selectedHere) bg = Colors.red.withOpacity(.12); return SizedBox(width: double.infinity, child: OutlinedButton(onPressed: answered ? null : () => answer(text), style: OutlinedButton.styleFrom(backgroundColor: bg, padding: const EdgeInsets.all(17), alignment: Alignment.centerLeft, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Row(children: [Expanded(child: Text(text, style: const TextStyle(fontSize: 16))), if (answered && correctHere) const Icon(Icons.check_circle, color: Colors.green), if (answered && selectedHere && !correctHere) const Icon(Icons.cancel, color: Colors.red)]))); }

  Widget _feedback() { final value = selected ?? (question.type == QuestionType.typing ? typing.text : assembled.join(' ')); final ok = norm(value) == norm(question.correctAnswer); return Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: ok ? Colors.green.withOpacity(.10) : Colors.red.withOpacity(.08), borderRadius: BorderRadius.circular(16)), child: Text(ok ? 'Дұрыс! Отлично 🎉' : 'Правильный ответ: ${question.correctAnswer}', style: TextStyle(fontWeight: FontWeight.bold, color: ok ? Colors.green.shade800 : Colors.red.shade800))); }

  Widget _speechHeader() { final target = vocabulary[q]; return Column(children: [const Text('Говори по-казахски', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800), textAlign: TextAlign.center), const SizedBox(height: 10), const Text('Произнеси слово вслух. Не бойся ошибиться — можно попробовать ещё раз.', style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center), const SizedBox(height: 28), Text(target.value, style: const TextStyle(fontSize: 18, color: Colors.grey)), const SizedBox(height: 8), Text(target.key, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900))]); }

  Widget _speechBody() => Column(children: [
    GestureDetector(onTap: answered ? null : startListening, child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: listening ? Colors.red.withOpacity(.12) : AppTheme.primary.withOpacity(.10), border: Border.all(color: listening ? Colors.red : AppTheme.primary, width: 3)), child: Icon(listening ? Icons.stop : Icons.mic, size: 58, color: listening ? Colors.red : AppTheme.primary))),
    const SizedBox(height: 18),
    Text(listening ? 'Слушаю… говори сейчас' : answered ? 'Распознавание завершено' : 'Нажми на микрофон и произнеси слово', style: const TextStyle(fontWeight: FontWeight.w600)),
    const SizedBox(height: 20),
    if (transcript.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: [const Text('Я услышал:', style: TextStyle(color: Colors.grey)), const SizedBox(height: 6), Text(transcript, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]))),
    const SizedBox(height: 14),
    if (!answered) SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: transcript.trim().isEmpty ? null : checkSpeech, child: const Text('Проверить произношение'))),
    if (answered) Card(color: AppTheme.primary.withOpacity(.08), child: Padding(padding: const EdgeInsets.all(15), child: Text(norm(transcript) == norm(vocabulary[q].key) ? 'Дұрыс! Отличное произношение 🎉' : 'Почти! Правильная фраза: ${vocabulary[q].key}', style: const TextStyle(fontWeight: FontWeight.bold)))),
  ]);

  Widget _bottom({required VoidCallback? onPressed, required String label}) => SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(label)))));

  Widget _result() { final total = widget.lesson.questions.length + speechCount; final percent = ((correct / total) * 100).round(); return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(percent >= 75 ? '🎉' : '💪', style: const TextStyle(fontSize: 80)), const SizedBox(height: 14), const Text('Урок завершён!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 10), Text('$correct из $total правильных • $percent%', style: const TextStyle(fontSize: 18)), const SizedBox(height: 8), Text('В том числе ${speechCount} задания с микрофоном 🎤', style: const TextStyle(color: Colors.grey)), const SizedBox(height: 8), Text('Всего XP: ${widget.player.xp}', style: const TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 28), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Вернуться к урокам')))])))); }
}
