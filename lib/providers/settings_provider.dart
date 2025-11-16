import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _ttsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get ttsEnabled => _ttsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(AppConstants.themeModeKey);
    if (mode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (mode == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    _ttsEnabled = prefs.getBool(AppConstants.ttsEnabledKey) ?? true;
    notifyListeners();
  }

  Future<void> updateTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeModeKey, _serializeMode(mode));
  }

  Future<void> setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.ttsEnabledKey, enabled);
  }

  String _serializeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
      default:
        return 'light';
    }
  }
}
