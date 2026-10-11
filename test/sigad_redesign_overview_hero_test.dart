import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';

void main() {
  testWidgets('card de visão geral é responsivo e abre a lista completa', (
    tester,
  ) async {
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
        home: const Scaffold(body: SigadDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atividades do departamento'), findsOneWidget);
    expect(
      find.text('Consulte os registros no painel operacional'),
      findsOneWidget,
    );
    expect(find.text('Quadro de trabalho'), findsOneWidget);
    expect(
      find.text('Acompanhe os itens do fluxo operacional'),
      findsOneWidget,
    );
    expect(find.text('Demandas do departamento'), findsOneWidget);
    expect(
      find.text('Disponível conforme as permissões do perfil'),
      findsOneWidget,
    );
    expect(find.text('Departamento de Eletroeletrônica'), findsOneWidget);
    expect(find.text('IFMA Campus Monte Castelo'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsAtLeastNWidgets(3));
    expect(find.text('Olá, usuário'), findsNothing);
    expect(find.text('Ver tudo'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final meetingButton = find.bySemanticsLabel(
      'Atividades do departamento. Consulte os registros no painel operacional',
    );
    expect(meetingButton, findsOneWidget);
    await tester.tap(meetingButton);
    await tester.pumpAndSettle();
    expect(find.text('Fechar'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ver tudo'));
    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();

    expect(find.text('Informações do departamento'), findsOneWidget);
    expect(find.text('Fechar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
