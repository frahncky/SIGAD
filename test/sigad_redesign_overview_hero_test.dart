import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/shared/widgets/welcome_hero.dart';

final _saudacao = RegExp(r'^(Bom dia|Boa tarde|Boa noite)');

Future<void> _pump(WidgetTester tester, WelcomeHero hero) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(2)),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: hero)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sem avisos mostra apenas as boas-vindas com a frase', (
    tester,
  ) async {
    await _pump(tester, const WelcomeHero(frase: 'Frase da semana.'));

    expect(find.textContaining(_saudacao), findsOneWidget);
    expect(find.text('Frase da semana.'), findsOneWidget);
    expect(find.bySemanticsLabel('Mostrar Avisos'), findsNothing);
  });

  testWidgets('com avisos alterna entre boas-vindas e avisos', (tester) async {
    await _pump(
      tester,
      WelcomeHero(
        avisos: const [
          WelcomeHeroItem(
            icon: SigadIcons.evento,
            title: 'Reunião de colegiado',
            subtitle: 'Hoje, 14h.',
          ),
        ],
      ),
    );

    expect(find.text('Reunião de colegiado'), findsNothing);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('1 aviso'), findsOneWidget);
    expect(find.text('Reunião de colegiado'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver todos os avisos'));
    await tester.tap(find.text('Ver todos os avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Hoje, 14h.'), findsWidgets);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.bySemanticsLabel('Mostrar Boas-vindas'));
    await tester.tap(find.bySemanticsLabel('Mostrar Boas-vindas'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_saudacao), findsOneWidget);
  });
  testWidgets('frase motivacional mantém contraste alto no cartão', (
    tester,
  ) async {
    const frase = 'Ensinar transforma o futuro.';
    await _pump(tester, const WelcomeHero(frase: frase));

    final texto = tester.widget<Text>(find.text(frase));
    expect(texto.style?.color, Colors.white);
    expect(texto.style?.fontWeight, FontWeight.w600);
    expect(tester.takeException(), isNull);
  });
}
