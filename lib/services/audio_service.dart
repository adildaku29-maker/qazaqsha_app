import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();
  final AudioPlayer _player = AudioPlayer();

  Future<void> speakAsset(String name) async {
    if (name == 'default') return;
    final source = 'audio/tanysu/$name.mp3';
    try {
      await _player.stop();
      await _player.setSource(AssetSource(source));
      await _player.resume();
      print('[QAZAQSHA][AUDIO] playing assets/$source');
    } catch (e) {
      print('[QAZAQSHA][AUDIO] FAILED assets/$source: $e');
    }
  }

  Future<void> dispose() => _player.dispose();
}
