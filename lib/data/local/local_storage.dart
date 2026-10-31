import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Qurilmadagi saqlash (SharedPreferences ustida).
///
/// Kalitlar markazlashgan — chiqishda faqat sessiyaga oid ma'lumotlar
/// o'chiriladi, sozlamalar (mavzu, til, onboarding) saqlanib qoladi.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> create() async =>
      LocalStorage(await SharedPreferences.getInstance());

  static const _session = 'session_v2';
  static const _onboarding = 'onboarding_seen';
  static const _themeMode = 'theme_mode';
  static const _language = 'language';
  static String _cartKey(String uid) => 'cart_$uid';
  static String _recentKey(String uid) => 'recent_$uid';
  static String _readingDaysKey(String uid) => 'reading_days_$uid';

  // Sessiya
  Map<String, dynamic>? readSession() {
    final raw = _prefs.getString(_session);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeSession(Map<String, dynamic> data) =>
      _prefs.setString(_session, jsonEncode(data));

  Future<void> clearSession() async {
    await _prefs.remove(_session);
    // Eski versiyadan qolgan kalit.
    await _prefs.remove('sharedData');
  }

  // Onboarding
  bool get onboardingSeen => _prefs.getBool(_onboarding) ?? false;
  Future<void> setOnboardingSeen() => _prefs.setBool(_onboarding, true);

  // Sozlamalar
  String? get themeMode => _prefs.getString(_themeMode);
  Future<void> setThemeMode(String v) => _prefs.setString(_themeMode, v);

  String? get language => _prefs.getString(_language);
  Future<void> setLanguage(String v) => _prefs.setString(_language, v);

  // Savat (foydalanuvchi bo'yicha)
  List<Map<String, dynamic>> readCart(String uid) =>
      _readList(_cartKey(uid));

  Future<void> writeCart(String uid, List<Map<String, dynamic>> items) =>
      _prefs.setString(_cartKey(uid), jsonEncode(items));

  // Yaqinda ko'rilganlar
  List<String> readRecent(String uid) =>
      _prefs.getStringList(_recentKey(uid)) ?? const [];

  Future<void> writeRecent(String uid, List<String> ids) =>
      _prefs.setStringList(_recentKey(uid), ids);

  // O'qish kunlari (seriya uchun), format: yyyy-MM-dd
  Set<String> readReadingDays(String uid) =>
      (_prefs.getStringList(_readingDaysKey(uid)) ?? const []).toSet();

  Future<void> writeReadingDays(String uid, Set<String> days) =>
      _prefs.setStringList(_readingDaysKey(uid), days.toList());

  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
