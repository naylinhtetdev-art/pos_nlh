import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(
    this._preferencesService, {
    ThemeMode initialMode = ThemeMode.system,
  }) : _mode = initialMode;

  final PreferencesService _preferencesService;

  ThemeMode _mode;

  ThemeMode get themeMode => _mode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await _preferencesService.saveThemeMode(mode);
  }
}
