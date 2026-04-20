import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/core/services/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('estado inicial é ThemeMode.light por padrão', () {
      final provider = ThemeProvider();
      expect(provider.mode, ThemeMode.light);
      expect(provider.isDark, isFalse);
    });

    test('inicializa em modo escuro quando isDark: true', () {
      final provider = ThemeProvider(isDark: true);
      expect(provider.mode, ThemeMode.dark);
      expect(provider.isDark, isTrue);
    });

    test('setDark(true) muda para ThemeMode.dark', () {
      final provider = ThemeProvider();
      provider.setDark(true);
      expect(provider.mode, ThemeMode.dark);
      expect(provider.isDark, isTrue);
    });

    test('setDark(false) muda para ThemeMode.light', () {
      final provider = ThemeProvider(isDark: true);
      provider.setDark(false);
      expect(provider.mode, ThemeMode.light);
      expect(provider.isDark, isFalse);
    });

    test('setDark com mesmo valor não dispara notifyListeners', () {
      final provider = ThemeProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setDark(false); // mesmo valor inicial

      expect(notified, isFalse);
    });

    test('setDark com valor diferente dispara notifyListeners', () {
      final provider = ThemeProvider();
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setDark(true);

      expect(notified, isTrue);
    });
  });
}
