import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère la langue active (français / arabe) avec persistence SharedPreferences.
///
/// Passer [locale] à MaterialApp déclenche automatiquement le RTL pour 'ar'.
///
/// Usage :
///   context.read<LocaleProvider>().setLocale(const Locale('ar'));
///   context.watch<LocaleProvider>().isArabic
class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale_code';

  Locale _locale = const Locale('fr');

  Locale get locale   => _locale;
  bool   get isArabic => _locale.languageCode == 'ar';

  /// Charge la langue sauvegardée au démarrage de l'app.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'fr';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Change la langue et sauvegarde la préférence.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  Future<void> setArabic(bool arabic) =>
      setLocale(Locale(arabic ? 'ar' : 'fr'));
}
