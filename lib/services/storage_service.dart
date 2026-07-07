import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tugasKey = 'akademik_tasks';
  static const String _avatarKey = 'profile_avatar';
  static const String _profileDataKey = 'profile_data';

  static Future<List<Map<String, dynamic>>?> loadTugasList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tugasKey);
    if (jsonString == null) return null;

    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> saveTugasList(List<Map<String, dynamic>> tugasList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tugasList);
    await prefs.setString(_tugasKey, jsonString);
  }

  static Future<Uint8List?> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_avatarKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  static Future<void> saveProfileImage(Uint8List? bytes) async {
    final prefs = await SharedPreferences.getInstance();
    if (bytes == null) {
      await prefs.remove(_avatarKey);
      return;
    }
    final encoded = base64Encode(bytes);
    await prefs.setString(_avatarKey, encoded);
  }

  static Future<Map<String, String>> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileDataKey);
    if (jsonString == null) return {};

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  static Future<void> saveProfileData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileDataKey, jsonEncode(data));
  }
}
