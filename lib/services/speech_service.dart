import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _stt=SpeechToText();
  final FlutterTts _tts=FlutterTts();
  Future<bool> init()=>_stt.initialize();
  Future<void> listen({required void Function(String) onText}) async {
    await _stt.listen(localeId:'kk_KZ',onResult:(r)=>onText(r.recognizedWords),listenOptions:SpeechListenOptions(partialResults:true,listenMode:ListenMode.dictation));
  }
  Future<void> stop()=>_stt.stop();
  Future<void> speak(String text) async {await _tts.setLanguage('kk-KZ');await _tts.setSpeechRate(.46);await _tts.speak(text);}
}