import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._locale);

  static const String _localeKey = 'app_locale';

  Locale _locale;

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  static Future<LocaleProvider> create() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguageCode = preferences.getString(_localeKey) ?? 'en';

    return LocaleProvider(Locale(savedLanguageCode));
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    await setLocale(Locale(isArabic ? 'en' : 'ar'));
  }
}
