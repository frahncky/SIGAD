import 'package:flutter/material.dart';

/// Gerencia o [ThemeMode] do app de forma reativa.
///
/// Inicialize com [isDark] lido da preferencia salva do usuario.
/// Use [setDark] para alternar o tema ao mudar a configuracao.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool isDark = false, String fontSizePreference = 'Médio'})
    : _mode = isDark ? ThemeMode.dark : ThemeMode.light,
      _fontScale = _scaleFor(fontSizePreference);

  ThemeMode _mode;
  double _fontScale;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  double get fontScale => _fontScale;

  void setDark(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
  }

  void setFontSizePreference(String preference) {
    final next = _scaleFor(preference);
    if (_fontScale == next) return;
    _fontScale = next;
    notifyListeners();
  }

  static double _scaleFor(String preference) {
    switch (preference) {
      case 'Pequeno':
        return 0.9;
      case 'Grande':
        return 1.15;
      case 'Médio':
      default:
        return 1;
    }
  }
}
