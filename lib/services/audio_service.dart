import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();
  final AudioPlayer _player = AudioPlayer();

  Future<void> speakAsset(String name) async {
    if (name == 'default') return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/tanysu/$name.mp3'));
    } catch (_) {
      // Audio files are supplied separately; missing audio must not break the lesson.
    }
  }

  Future<void> dispose() => _player.dispose();
}
