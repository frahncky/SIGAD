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
  testWidgets('resumo compacto abre conteúdo completo com fonte ampliada', (
    tester,
  ) async {
    await _pump(
      tester,
      WelcomeHero(
        paginaInicial: 1,
        rotacaoAutomatica: false,
        resumo: const [
          WelcomeHeroItem(
            icon: SigadIcons.predio,
            title: 'Laboratórios disponíveis',
            subtitle: 'Consulte a disponibilidade dos espaços do departamento.',
          ),
          WelcomeHeroItem(
            icon: SigadIcons.evento,
            title: 'Atividades do departamento',
            subtitle: 'Consulte as atividades previstas para esta semana.',
          ),
          WelcomeHeroItem(
            icon: SigadIcons.aviso,
            title: 'Informações do departamento',
            subtitle: 'Consulte os detalhes completos do resumo.',
          ),
        ],
      ),
    );
    expect(find.text('Laboratórios disponíveis'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Ver tudo'));
    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text('Consulte os detalhes completos do resumo.'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem avisos mostra apenas as boas-vindas com a frase', (
    tester,
  ) async {
    await _pump(tester, const WelcomeHero(frase: 'Frase da semana.'));

    expect(find.textContaining(_saudacao), findsNothing);
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
    expect(find.textContaining(_saudacao), findsNothing);
  });
  testWidgets('frase motivacional mantém contraste alto no cartão', (
    tester,
  ) async {
    const frase = 'Ensinar transforma o futuro.';
    await _pump(tester, const WelcomeHero(frase: frase));

    final texto = tester.widget<Text>(find.text(frase));
    final fundo = tester.widget<Container>(
      find.byKey(const Key('welcome-hero')),
    );
    final corFundo = (fundo.decoration! as BoxDecoration).color!;
    final corTexto = texto.style!.color!;
    final contraste =
        (corFundo.computeLuminance() + 0.05) /
        (corTexto.computeLuminance() + 0.05);
    expect(corTexto.a, 1);
    expect(contraste, greaterThanOrEqualTo(4.5));

    expect(tester.takeException(), isNull);
  });
}
