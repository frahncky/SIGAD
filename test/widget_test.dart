import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/app/app.dart';
import 'package:sigad/core/services/locale_provider.dart';

void main() {
  Future<void> abrirApp(
    WidgetTester tester, {
    required Locale aparelho,
    LocaleProvider? idioma,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    tester.platformDispatcher.localesTestValue = [aparelho];
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearLocalesTestValue();
    });

    await tester.pumpWidget(SigadApp(localeProvider: idioma));
    await tester.pumpAndSettle();
  }

  testWidgets('celular em português abre o login em português', (tester) async {
    await abrirApp(tester, aparelho: const Locale('pt', 'BR'));

    expect(find.text('Email institucional'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('celular em inglês abre o login em inglês', (tester) async {
    await abrirApp(tester, aparelho: const Locale('en', 'US'));

    expect(find.text('Institutional email'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('celular em outro idioma usa português', (tester) async {
    await abrirApp(tester, aparelho: const Locale('es', 'ES'));

    expect(find.text('Email institucional'), findsOneWidget);
  });

  testWidgets('idioma escolhido nas configurações vale sobre o do celular', (
    tester,
  ) async {
    await abrirApp(
      tester,
      aparelho: const Locale('pt', 'BR'),
      idioma: LocaleProvider(idioma: LocaleProvider.ingles),
    );

    expect(find.text('Institutional email'), findsOneWidget);
  });
}
