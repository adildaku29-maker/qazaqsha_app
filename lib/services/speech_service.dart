import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isListening = false;
  void Function(String text)? _onText;

  static const String serverUrl = String.fromEnvironment(
    'ASR_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  bool get isListening => _isListening;

  Future<double> getRecorderAmplitude() async {
    final amplitude = await _recorder.getAmplitude();
    return amplitude.current;
  }

  Future<bool> init() => initialize();

  Future<bool> initialize() async {
    final granted = await _recorder.hasPermission();
    print('[QAZAQSHA][MIC] permission=$granted');
    return granted;
  }

  Future<bool> listen({void Function(String text)? onText}) async {
    if (_isListening) return true;

    _onText = onText;
    print('[QAZAQSHA][MIC] listen() started');

    final hasPermission = await _recorder.hasPermission();
    print('[QAZAQSHA][MIC] permission=$hasPermission');
    if (!hasPermission) {
      _onText = null;
      return false;
    }

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

      // Do not call isRecording() here. On some Android/record plugin
      // combinations that platform Future can remain pending even though
      // the native recorder has already started successfully.
      _isListening = true;

      print(
        '[QAZAQSHA][MIC] AudioRecorder.start() SUCCESS '
        'nativeRecording=true',
      );

      return true;
    } catch (e, stack) {
      try {
        final nativeRecording = await _recorder.isRecording();
        if (nativeRecording) {
          _isListening = true;
          print(
            '[QAZAQSHA][MIC] start() reported ERROR, '
            'but native recorder is ACTIVE: $e',
          );
          return true;
        }
      } catch (stateError) {
        print('[QAZAQSHA][MIC] failed to read native state: $stateError');
      }

      _isListening = false;
      _onText = null;
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

    if (path == null) {
      _onText = null;
      return null;
    }

    try {
      final text = await _sendToWhisper(path);
      if (text != null && _onText != null) {
        _onText!(text);
      }
      return text;
    } finally {
      _onText = null;
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

    final response =
        await request.send().timeout(const Duration(seconds: 45));
    final body = await response.stream.bytesToString();

    print(
      '[QAZAQSHA][ASR] response=${response.statusCode} body=$body',
    );

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
      _onText = null;

      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
  }

  Future<void> speak(String text) async {
    await _player.stop();

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/synthesize'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/qazaqsha_tts_${DateTime.now().microsecondsSinceEpoch}.mp3',
        );
        await file.writeAsBytes(response.bodyBytes, flush: true);
        await _player.play(DeviceFileSource(file.path));
        return;
      }
    } catch (_) {}

    final asset = _assetFor(text);
    if (asset != null) {
      await _player.play(AssetSource(asset));
    }
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

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
