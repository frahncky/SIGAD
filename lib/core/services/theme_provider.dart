import 'package:flutter/material.dart';

/// Gerencia o [ThemeMode] e o tamanho do texto do app de forma reativa.
///
/// Inicialize com [isDark] e [tamanhoTexto] lidos da preferência salva do
/// usuário. Use [setDark] e [setTamanhoTexto] ao mudar a configuração.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool isDark = false, String? tamanhoTexto})
    : _mode = isDark ? ThemeMode.dark : ThemeMode.light,
      _tamanhoTexto = normalizarTamanho(tamanhoTexto);

  /// Opções de tamanho do texto e o quanto cada uma amplia o texto, sobre a
  /// escala escolhida no sistema do aparelho.
  static const tamanhosTexto = {
    'Normal': 1.0,
    'Médio': 1.1,
    'Grande': 1.25,
    'Muito grande': 1.4,
  };

  static const tamanhoPadrao = 'Médio';

  /// Converte valores salvos (inclusive os antigos) para uma opção válida.
  static String normalizarTamanho(String? valor) {
    if (valor == 'Pequeno') return 'Normal';
    return tamanhosTexto.containsKey(valor) ? valor! : tamanhoPadrao;
  }

  ThemeMode _mode;
  String _tamanhoTexto;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  String get tamanhoTexto => _tamanhoTexto;
  double get fatorTexto => tamanhosTexto[_tamanhoTexto]!;

  void setDark(bool dark) {
    final next = dark ? ThemeMode.dark : ThemeMode.light;
    if (_mode == next) return;
    _mode = next;
    notifyListeners();
  }

  void setTamanhoTexto(String tamanho) {
    final next = normalizarTamanho(tamanho);
    if (_tamanhoTexto == next) return;
    _tamanhoTexto = next;
    notifyListeners();
  }
}
