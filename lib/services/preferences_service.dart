import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class PreferencesService {
  static const String _themeModeKey = 'theme_mode';

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    switch (modeString) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
} 