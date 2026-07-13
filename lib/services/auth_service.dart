import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loggedInKey = 'akademik_logged_in';
  static const String _userEmailKey = 'akademik_user_email';
  static const String _userNameKey = 'akademik_user_name';

  static bool isLoggedIn = false;
  static String userEmail = '';
  static String userName = '';
  static final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  static Future<void> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    userEmail = prefs.getString(_userEmailKey) ?? '';
    userName = prefs.getString(_userNameKey) ?? '';
    authNotifier.value = isLoggedIn;
  }

  static Future<bool> login(String name, String email, String password) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = true;
    userEmail = email.trim();
    userName = name.trim();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_userEmailKey, userEmail);
    await prefs.setString(_userNameKey, userName);
    authNotifier.value = true;
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    isLoggedIn = false;
    userEmail = '';
    userName = '';
    authNotifier.value = false;
  }
}
