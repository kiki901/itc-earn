import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = Locale('ar', 'SA');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(langCode, langCode == 'ar' ? 'SA' : langCode == 'fr' ? 'FR' : 'US');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['ar', 'en', 'fr'].contains(locale.languageCode)) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
}
