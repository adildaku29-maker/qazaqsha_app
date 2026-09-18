import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  String? _kazakhLocale;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    if (_initialized) {
      final locales = await _speech.locales();
      for (final locale in locales) {
        final id = locale.localeId.toLowerCase().replaceAll('_', '-');
        if (id == 'kk-kz' || id.startsWith('kk-')) {
          _kazakhLocale = locale.localeId;
          break;
        }
      }
    }
    return _initialized;
  }

  Future<bool> listen({required void Function(SpeechRecognitionResult) onResult}) async {
    final ok = await initialize();
    if (!ok) return false;
    await _speech.listen(
      onResult: onResult,
      localeId: _kazakhLocale ?? 'kk_KZ',
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
      ),
    );
    return true;
  }

  Future<void> stop() => _speech.stop();
  Future<void> cancel() => _speech.cancel();
}
