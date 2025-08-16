// lib/core/constants/pref_data.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefData {
  static const String isLoggedInKey = "is_logged_in";

  /// Sets the login status.
  static Future<void> setLogIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  /// Retrieves the login status.
  static Future<bool> getLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }
}
