import 'package:flutter/material.dart';

import '../data/local/local_storage.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage) {
    _themeMode = switch (_storage.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final lang = _storage.language;
    _locale = Locale(
      (lang == 'ru' || lang == 'en' || lang == 'uz') ? lang! : 'uz',
    );
  }

  final LocalStorage _storage;

  late ThemeMode _themeMode;
  late Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get onboardingSeen => _storage.onboardingSeen;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storage.setThemeMode(mode.name);
  }

  Future<void> setLanguage(String code) async {
    _locale = Locale(code);
    notifyListeners();
    await _storage.setLanguage(code);
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingSeen();
    notifyListeners();
  }
}
