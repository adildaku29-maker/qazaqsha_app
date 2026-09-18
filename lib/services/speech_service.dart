import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeechService {
  static const String _serverUrl =
      String.fromEnvironment('ASR_URL', defaultValue: 'http://10.0.2.2:8000');

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  void Function(String text)? _onText;

  Future<bool> init() => _recorder.hasPermission();

  Future<void> listen({required void Function(String) onText}) async {
    if (!await _recorder.hasPermission()) return;
    _onText = onText;
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/qazaqsha_voice.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        echoCancel: true,
        noiseSuppress: true,
        autoGain: true,
      ),
      path: path,
    );
  }

  Future<void> stop() async {
    final path = await _recorder.stop();
    if (path == null) return;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_serverUrl/transcribe'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          path,
          filename: 'qazaqsha.wav',
        ),
      );

      final response = await request.send().timeout(const Duration(seconds: 45));
      final body = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        throw Exception('ASR ${response.statusCode}: $body');
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final text = (json['text'] as String?)?.trim() ?? '';
      if (text.isNotEmpty) _onText?.call(text);
    } catch (_) {
      _onText?.call('');
    } finally {
      _onText = null;
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<void> speak(String text) async {
    final asset = _assetFor(text);
    if (asset == null) return;
    await _player.stop();
    await _player.play(AssetSource(asset));
  }

  String? _assetFor(String text) {
    const map = <String, String>{
      'сәлем': 'audio/tanisu/salem.mp3',
      'аты': 'audio/tanisu/aty.mp3',
      'жас': 'audio/tanisu/zhas.mp3',
      'Сәлем! Қалың қалай?': 'audio/tanisu/salam_kalyn_kalay.mp3',
      'Атың кім?': 'audio/tanisu/atyn_kim.mp3',
      'Қай қалада тұрасың?': 'audio/tanisu/kay_kalada_turasyn.mp3',
    };
    return map[text];
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
