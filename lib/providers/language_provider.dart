import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider(
    this._preferencesService, {
    Locale initialLocale = const Locale('en'),
  }) : _locale = initialLocale;

  static const Locale english = Locale('en');
  static const Locale myanmar = Locale('my');

  final PreferencesService _preferencesService;

  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _preferencesService.saveLocale(locale);
  }
}
