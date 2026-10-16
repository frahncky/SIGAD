import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/mais/presentation/pages/mais_page.dart';
import 'package:sigad/features/mural/presentation/state/mural_controller.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';

void _setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _tile(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first;

Future<void> _pumpOverview(
  WidgetTester tester, {
  required Size size,
  double scale = 1,
}) async {
  _setScreen(tester, size);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const Scaffold(body: SigadDashboardPage()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Carga docente'));
  await tester.pumpAndSettle();
}

Future<void> _pumpMais(WidgetTester tester, {required Size size}) async {
  _setScreen(tester, size);
  final userContext = UserContextProvider();
  await userContext.login(
    User(
      id: 'test-coord',
      name: 'Usuária de teste',
      email: 'teste@exemplo.edu.br',
      role: UserRole.coordenador,
      createdAt: DateTime(2026),
    ),
  );
  final mural = MuralController();
  await mural.carregar();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
        ChangeNotifierProvider<MuralController>.value(value: mural),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: MaisPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Carga docente'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('visão geral exibe três atalhos por linha em 390 px', (
    tester,
  ) async {
    await _pumpOverview(tester, size: const Size(390, 844));

    final a = tester.getTopLeft(_tile('Carga docente'));
    final b = tester.getTopLeft(_tile('Laboratórios'));
    final c = tester.getTopLeft(_tile('Notícias'));

    expect((a.dy - b.dy).abs(), lessThan(1));
    expect((b.dy - c.dy).abs(), lessThan(1));
    expect(a.dx, lessThan(b.dx));
    expect(b.dx, lessThan(c.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('visão geral reduz colunas com fonte ampliada', (tester) async {
    await _pumpOverview(tester, size: const Size(320, 568), scale: 2);

    final a = tester.getTopLeft(_tile('Carga docente'));
    final b = tester.getTopLeft(_tile('Laboratórios'));
    final c = tester.getTopLeft(_tile('Notícias'));

    expect((a.dy - b.dy).abs(), lessThan(1));
    expect(c.dy, greaterThan(b.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tela Mais organiza acessos em três colunas compactas', (
    tester,
  ) async {
    await _pumpMais(tester, size: const Size(390, 844));

    final a = tester.getTopLeft(_tile('Carga docente'));
    final b = tester.getTopLeft(_tile('Professores'));
    final c = tester.getTopLeft(_tile('Laboratórios'));

    expect((a.dy - b.dy).abs(), lessThan(1));
    expect((b.dy - c.dy).abs(), lessThan(1));
    expect(a.dx, lessThan(b.dx));
    expect(b.dx, lessThan(c.dx));
    expect(tester.takeException(), isNull);
  });
}
