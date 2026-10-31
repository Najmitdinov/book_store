import 'package:flutter/material.dart';

part 'strings_uz.dart';
part 'strings_ru.dart';
part 'strings_en.dart';

/// Yengil, kod generatsiyasiz lokalizatsiya (o'zbek, rus, ingliz).
///
/// Foydalanish: `context.tr('login')` yoki
/// `context.tr('goal_progress', {'done': '3', 'goal': '12'})`.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('uz'), Locale('ru'), Locale('en')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('uz'));
  }

  static const Map<String, Map<String, String>> _all = {
    'uz': _uz,
    'ru': _ru,
    'en': _en,
  };

  String get(String key, [Map<String, String>? args]) {
    var value = _all[locale.languageCode]?[key] ?? _uz[key] ?? key;
    args?.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['uz', 'ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension TrX on BuildContext {
  String tr(String key, [Map<String, String>? args]) =>
      AppLocalizations.of(this).get(key, args);

  String get langCode => AppLocalizations.of(this).locale.languageCode;
}
