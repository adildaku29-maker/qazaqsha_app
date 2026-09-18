import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';

class StorageService {
  static const String _playerKey = 'qazaqsha_player_v2';

  static Future<Player?> getPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_playerKey);
    if (str == null) return null;
    try {
      return Player.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  static Future<void> savePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey, jsonEncode(player.toJson()));
  }

  static Future<void> clearPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerKey);
  }
}
