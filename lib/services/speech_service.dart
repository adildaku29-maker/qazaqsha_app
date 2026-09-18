import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeechService {
  static const String _serverUrl =
      String.fromEnvironment('ASR_URL', defaultValue: 'http://10.0.2.2:8000');

  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> init() => _recorder.hasPermission();

  Future<String?> startRecording() async {
    if (!await _recorder.hasPermission()) return null;

    final dir = await getTemporaryDirectory();
    final path = '\${dir.path}/qazaqsha_voice.wav';

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

    return path;
  }

  Future<String?> stopAndTranscribe() async {
    final path = await _recorder.stop();
    if (path == null) return null;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('\$_serverUrl/transcribe'),
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
      return (json['text'] as String?)?.trim();
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Future<void> cancel() async {
    await _recorder.cancel();
  }

  void dispose() {
    _recorder.dispose();
  }
}
