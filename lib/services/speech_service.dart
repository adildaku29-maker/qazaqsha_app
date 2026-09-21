import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isListening = false;

  static const String serverUrl = String.fromEnvironment(
    'ASR_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    final granted = await _recorder.hasPermission();
    print('[QAZAQSHA][MIC] permission=$granted');
    return granted;
  }

  Future<bool> listen() async {
    if (_isListening) return true;

    print('[QAZAQSHA][MIC] listen() started');

    final hasPermission = await _recorder.hasPermission();
    print('[QAZAQSHA][MIC] permission=$hasPermission');
    if (!hasPermission) return false;

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/qazaqsha_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    print('[QAZAQSHA][MIC] recording path=$path');
    print('[QAZAQSHA][MIC] calling AudioRecorder.start()');

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.defaultSource,
            manageBluetooth: false,
          ),
        ),
        path: path,
      );

      _isListening = true;
      print('[QAZAQSHA][MIC] AudioRecorder.start() SUCCESS');
      return true;
    } catch (e, stack) {
      _isListening = false;
      print('[QAZAQSHA][MIC] AudioRecorder.start() ERROR: $e');
      print(stack);
      rethrow;
    }
  }

  Future<String?> stop() async {
    if (!_isListening) return null;

    print('[QAZAQSHA][MIC] stop()');
    final path = await _recorder.stop();
    _isListening = false;
    print('[QAZAQSHA][MIC] recorder stopped: $path');

    if (path == null) return null;

    try {
      return await _sendToWhisper(path);
    } finally {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<String?> _sendToWhisper(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    print('[QAZAQSHA][ASR] uploading $path to $serverUrl/transcribe');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$serverUrl/transcribe'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        path,
        filename: 'recording.wav',
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('[QAZAQSHA][ASR] response=${response.statusCode} body=$body');

    if (response.statusCode != 200) {
      throw Exception(
        'Whisper server error ${response.statusCode}: $body',
      );
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['text']?.toString().trim();
  }

  Future<void> cancel() async {
    if (_isListening) {
      print('[QAZAQSHA][MIC] cancel()');
      final path = await _recorder.stop();
      _isListening = false;

      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
