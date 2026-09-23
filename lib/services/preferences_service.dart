import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';
  static const String _isLoginKey = 'is_login';

  final SharedPreferences _prefs;

  bool isLoggedIn() => _prefs.getBool(_isLoginKey) ?? false;

  Future<void> setIsLoggedIn(bool value) => _prefs.setBool(_isLoginKey, value);

  ThemeMode loadThemeMode() {
    return switch (_prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeModeKey, mode.name);
  }

  Locale loadLocale() {
    return Locale(_prefs.getString(_languageCodeKey) ?? 'en');
  }

  Future<void> saveLocale(Locale locale) {
    return _prefs.setString(_languageCodeKey, locale.languageCode);
  }
}
