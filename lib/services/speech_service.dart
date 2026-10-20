import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isListening = false;
  void Function(String text)? _onText;
  void Function(String text)? _onPartialText;
  WebSocket? _socket;
  StreamSubscription<Uint8List>? _audioSubscription;
  final Completer<String?> _finalText = Completer<String?>();

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

  Future<bool> listen({
    void Function(String text)? onText,
    void Function(String text)? onPartialText,
  }) async {
    if (_isListening) return true;

    _onText = onText;
    _onPartialText = onPartialText;

    final hasPermission = await _recorder.hasPermission();
    print('[QAZAQSHA][MIC] permission=$hasPermission');
    if (!hasPermission) {
      _clearCallbacks();
      return false;
    }

    try {
      final wsUrl = Uri.parse(
        serverUrl.replaceFirst('https://', 'wss://').replaceFirst(
              'http://',
              'ws://',
            ) +
            '/stream',
      );

      print('[QAZAQSHA][STREAM] connecting to $wsUrl');
      _socket = await WebSocket.connect(
        wsUrl.toString(),
      ).timeout(const Duration(seconds: 10));

      _socketSubscriptionSetup();

      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          androidConfig: AndroidRecordConfig(
            audioSource: AndroidAudioSource.defaultSource,
            manageBluetooth: false,
          ),
        ),
      );

      _audioSubscription = audioStream.listen(
        (chunk) {
          final socket = _socket;
          if (socket != null && socket.readyState == WebSocket.open) {
            socket.add(chunk);
          }
        },
        onError: (Object error, StackTrace stack) {
          print('[QAZAQSHA][STREAM] microphone stream error: $error');
          if (!_finalText.isCompleted) {
            _finalText.completeError(error, stack);
          }
        },
      );

      _isListening = true;
      print('[QAZAQSHA][STREAM] microphone streaming to server');
      return true;
    } catch (e, stack) {
      print('[QAZAQSHA][STREAM] start ERROR: $e');
      print(stack);
      await _closeStream(sendCancel: true);
      _clearCallbacks();
      rethrow;
    }
  }

  void _socketSubscriptionSetup() {
    _socket!.listen(
      (dynamic message) {
        if (message is! String) return;

        try {
          final data = jsonDecode(message) as Map<String, dynamic>;
          final type = data['type']?.toString();
          final text = data['text']?.toString().trim() ?? '';

          if (type == 'partial' && text.isNotEmpty) {
            print('[QAZAQSHA][STREAM] partial: $text');
            _onPartialText?.call(text);
          } else if (type == 'final') {
            print('[QAZAQSHA][STREAM] final: $text');
            if (!_finalText.isCompleted) _finalText.complete(text);
          } else if (type == 'error') {
            final error = data['message']?.toString() ?? 'Unknown ASR error';
            if (!_finalText.isCompleted) {
              _finalText.completeError(Exception(error));
            }
          }
        } catch (e) {
          print('[QAZAQSHA][STREAM] invalid server message: $e');
        }
      },
      onError: (Object error, StackTrace stack) {
        print('[QAZAQSHA][STREAM] socket error: $error');
        if (!_finalText.isCompleted) _finalText.completeError(error, stack);
      },
      onDone: () {
        print('[QAZAQSHA][STREAM] socket closed');
        if (!_finalText.isCompleted) _finalText.complete(null);
      },
      cancelOnError: false,
    );
  }

  Future<String?> stop() async {
    if (!_isListening) return null;

    print('[QAZAQSHA][STREAM] stopping microphone');
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    try {
      await _recorder.stop();
    } catch (e) {
      print('[QAZAQSHA][MIC] stop warning: $e');
    }

    _isListening = false;

    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) {
      await _closeStream();
      _clearCallbacks();
      return null;
    }

    socket.add(jsonEncode({'type': 'finish'}));

    try {
      final text = await _finalText.future.timeout(
        const Duration(seconds: 45),
      );
      if (text != null && text.isNotEmpty) _onText?.call(text);
      return text;
    } finally {
      await _closeStream();
      _clearCallbacks();
    }
  }

  Future<void> _closeStream({bool sendCancel = false}) async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    final socket = _socket;
    _socket = null;

    if (socket != null) {
      try {
        if (sendCancel && socket.readyState == WebSocket.open) {
          socket.add(jsonEncode({'type': 'cancel'}));
        }
        await socket.close();
      } catch (_) {}
    }

    _isListening = false;
  }

  void _clearCallbacks() {
    _onText = null;
    _onPartialText = null;
  }

  Future<void> cancel() async {
    if (_isListening) {
      print('[QAZAQSHA][STREAM] cancel()');
      try {
        await _audioSubscription?.cancel();
        _audioSubscription = null;
        await _recorder.stop();
      } catch (e) {
        print('[QAZAQSHA][STREAM] cancel warning: $e');
      }
    }

    await _closeStream(sendCancel: true);
    _clearCallbacks();
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
    await cancel();
    await _recorder.dispose();
    await _player.dispose();
  }
}
