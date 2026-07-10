import 'package:flutter/material.dart';

/// Gerencia o [ThemeMode] do app de forma reativa.
///
/// Inicialize com [isDark] lido da preferencia salva do usuario.
/// Use [setDark] para alternar o tema ao mudar a configuracao.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool isDark = false})
    : _mode = isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeMode _mode;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
  }
}
