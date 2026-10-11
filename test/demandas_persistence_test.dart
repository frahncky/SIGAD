import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/demandas/data/demanda_repository.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/demandas/domain/demandas_service.dart';
import 'package:sigad/features/demandas/presentation/pages/demandas_page.dart';

class ControlledRepository extends DemandaRepository {
  Completer<void> pending = Completer<void>();
  int calls = 0;
  @override
  Future<List<Demanda>> loadDemandas() async =>
      DemandasService.defaultDemandas();
  @override
  Future<void> saveDemandas(List<Demanda> demandas) {
    calls++;
    return pending.future;
  }
}

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
Future<void> openForm(WidgetTester tester, ControlledRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final userContext = UserContextProvider();
  addTearDown(userContext.dispose);
  await userContext.login(
    User(
      id: 'test',
      name: 'Teste',
      email: 'test@ifma.edu.br',
      role: UserRole.coordenador,
      createdAt: DateTime(2026),
    ),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: userContext,
      child: MaterialApp(home: DemandasPage(repository: repo)),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Criar nova demanda'));
  await tester.pumpAndSettle();
  await tester.enterText(field('Título'), 'Demanda persistida');
  await tester.enterText(field('Descrição'), 'Descrição da demanda persistida');
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Criar'));
  await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
  await tester.pump();
}

void main() {
  testWidgets('coleção persistida vazia não ressuscita exemplos ao reabrir', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = DemandaRepository(storageKey: 'test_empty');
    await repo.saveDemandas(DemandasService.defaultDemandas());
    await repo.saveDemandas([]);
    final userContext = UserContextProvider();
    addTearDown(userContext.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: userContext,
        child: MaterialApp(home: DemandasPage(repository: repo)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma demanda encontrada'), findsOneWidget);
    expect(find.byIcon(SigadIcons.maisOpcoes), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('aguarda gravação e bloqueia envio duplicado antes do sucesso', (
    tester,
  ) async {
    final repo = ControlledRepository();
    await openForm(tester, repo);
    expect(repo.calls, 1);
    expect(find.text('Nova Demanda'), findsOneWidget);
    expect(find.text('Demanda criada com sucesso!'), findsNothing);
    final submit = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Salvando...'),
    );
    expect(submit.onPressed, isNull);
    repo.pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Nova Demanda'), findsNothing);
    expect(find.text('Demanda criada com sucesso!'), findsOneWidget);
    expect(repo.calls, 1);
  });
  testWidgets('falha preserva formulário e permite tentativa posterior', (
    tester,
  ) async {
    final repo = ControlledRepository();
    await openForm(tester, repo);
    repo.pending.completeError(StateError('Falha de persistência'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Demanda'), findsOneWidget);
    expect(
      tester.widget<TextField>(field('Título')).controller!.text,
      'Demanda persistida',
    );
    expect(find.text('Demanda criada com sucesso!'), findsNothing);
    repo.pending = Completer<void>();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
    await tester.pump();
    expect(repo.calls, 2);
    repo.pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Demanda criada com sucesso!'), findsOneWidget);
  });
}
