import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sigad/features/mural/domain/mural_models.dart';
import 'package:sigad/features/mural/presentation/state/mural_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void configureView(WidgetTester tester, {required Size size}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<UserContextProvider> loggedInContext({
    UserRole role = UserRole.coordenador,
  }) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord_1',
        name: 'Maria Santos',
        email: 'maria.santos@ifma.edu.br',
        role: role,
        createdAt: DateTime.now(),
      ),
    );
    return userContext;
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    UserRole role = UserRole.coordenador,
    Size size = const Size(390, 844),
    double textScale = 1,
    List<Aviso> avisos = const [],
  }) async {
    configureView(tester, size: size);
    final userContext = await loggedInContext(role: role);
    final mural = MuralController();
    await mural.carregar();
    for (final aviso in avisos) {
      await mural.salvarAviso(aviso);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserContextProvider>.value(
              value: userContext,
            ),
            ChangeNotifierProvider<MuralController>.value(value: mural),
          ],
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> irParaSlide(WidgetTester tester, String rotulo) async {
    final dot = find.bySemanticsLabel('Mostrar $rotulo');
    await tester.ensureVisible(dot);
    await tester.tap(dot);
    await tester.pumpAndSettle();
  }

  testWidgets('topo mostra boas-vindas e não exibe card de resumo separado', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.byKey(const Key('welcome-hero')), findsOneWidget);
    expect(find.textContaining(RegExp(r', Maria!$')), findsOneWidget);
    expect(find.byKey(const Key('dashboard-alerts-card')), findsNothing);
    expect(find.text('Acesso rápido'), findsOneWidget);
    expect(find.byTooltip('Personalizar atalhos'), findsOneWidget);
    expect(find.text('Atenção agora'), findsOneWidget);
  });

  testWidgets('resumo do departamento é um slide do card do topo', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await irParaSlide(tester, 'Resumo do departamento');
    expect(find.text('Atividades do departamento'), findsOneWidget);
    expect(find.text('Quadro de trabalho'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsOneWidget);
    expect(find.text('0 atividades registradas'), findsOneWidget);
    expect(find.text('0 demandas registradas'), findsOneWidget);

    await tester.tap(find.text('Ver tudo'));
    await tester.pumpAndSettle();
    expect(find.text('Fechar'), findsOneWidget);
  });

  final avisoReuniao = Aviso(
    id: 'a1',
    modelo: ModeloAviso.evento,
    titulo: 'Reunião de colegiado',
    conteudo: 'Hoje, 14h, sala 305.',
    criadoEm: DateTime(2026),
  );

  testWidgets('sem avisos no mural não há slide de avisos', (tester) async {
    await pumpDashboard(tester);
    expect(find.bySemanticsLabel('Mostrar Avisos'), findsNothing);
  });

  testWidgets('rotação automática passa pelos avisos', (tester) async {
    await pumpDashboard(tester, avisos: [avisoReuniao]);

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Ver todos os avisos'), findsOneWidget);
    expect(find.text('Reunião de colegiado'), findsOneWidget);
  });

  testWidgets('professor recebe resumo compatível com o perfil', (
    tester,
  ) async {
    await pumpDashboard(tester, role: UserRole.professor);

    await irParaSlide(tester, 'Resumo do departamento');
    expect(find.text('Acesso ao departamento'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsNothing);
  });

  testWidgets('não apresenta overflow em 320x568 com texto a 200%', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      size: const Size(320, 568),
      textScale: 2,
      avisos: [avisoReuniao],
    );

    for (final rotulo in ['Avisos', 'Resumo do departamento', 'Boas-vindas']) {
      await irParaSlide(tester, rotulo);
    }
  });
}
