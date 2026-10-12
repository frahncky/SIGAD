import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/atividades/domain/atividades_service.dart';
import 'package:sigad/features/atividades/presentation/atividades_l10n.dart';
import 'package:sigad/features/atividades/presentation/pages/atividades_page.dart';
import 'package:sigad/features/kanban/domain/kanban_service.dart';
import 'package:sigad/features/kanban/presentation/kanban_l10n.dart';
import 'package:sigad/features/kanban/presentation/pages/kanban_page.dart';
import 'package:sigad/l10n/l10n.dart';

Future<void> _pump(WidgetTester tester, Widget page, Locale locale) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: page,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final en = lookupAppLocalizations(const Locale('en'));

  test('colunas, prioridades e validação do quadro têm tradução', () {
    for (final valor in [
      ...KanbanService.colunas.where((c) => c != 'Backlog'),
      ...KanbanService.prioridades,
    ]) {
      expect(en.opcaoKanban(valor), isNot(valor), reason: valor);
    }
    final erro = KanbanService.validateTitulo('');
    expect(en.erroKanban(erro!), isNot(erro));
  });

  test('status e validações das atividades têm tradução', () {
    for (final status in AtividadesService.statusAtividade) {
      expect(en.statusAtividade(status), isNot(status), reason: status);
    }
    for (final erro in [
      AtividadesService.validarAtividade(titulo: '', descricao: 'x'),
      AtividadesService.validarAtividade(titulo: 'x', descricao: ''),
    ]) {
      expect(en.erroAtividade(erro!), isNot(erro));
    }
  });

  testWidgets('quadro de tarefas em português e inglês', (tester) async {
    await _pump(tester, const KanbanPage(), const Locale('pt'));
    expect(find.text('Em Progresso'), findsOneWidget);

    await _pump(tester, const KanbanPage(), const Locale('en'));
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('High'), findsWidgets);

    await tester.tap(find.byTooltip('New card'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the card title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('atividades em português e inglês', (tester) async {
    await _pump(tester, const AtividadesPage(), const Locale('pt'));
    expect(find.text('Agenda operacional'), findsOneWidget);

    await _pump(tester, const AtividadesPage(), const Locale('en'));
    expect(find.text('Operational agenda'), findsOneWidget);
    expect(find.byTooltip('Filter activities'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);

    await tester.tap(find.byTooltip('Create new activity'));
    await tester.pumpAndSettle();
    expect(find.text('New Activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
