import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class StorageService {
  static const _key = 'qazaqsha_player_v3';

  static Future<Player?> getPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return Player.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(player.toJson()));
  }

  static Future<void> clearPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
