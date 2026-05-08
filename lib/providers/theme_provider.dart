import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le mode d'affichage (clair / sombre) avec persistence SharedPreferences.
///
/// Usage :
///   context.read<ThemeProvider>().toggle();
///   context.watch<ThemeProvider>().isDark
class ThemeProvider extends ChangeNotifier {
  static const _key = 'dark_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode  => _mode;
  bool      get isDark => _mode == ThemeMode.dark;

  /// Charge la préférence sauvegardée au démarrage de l'app.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key) ?? false;
    _mode = saved ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Bascule entre mode clair et sombre et sauvegarde la préférence.
  Future<void> toggle() => setDark(!isDark);

  /// Applique le mode demandé et sauvegarde.
  Future<void> setDark(bool dark) async {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, dark);
  }
}
