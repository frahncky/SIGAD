import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  const testAlerts = [
    DashboardAlertItem(
      icon: Icons.event_note_outlined,
      title: 'Atividades do departamento',
      subtitle: '3 atividades registradas',
      tone: Color(0xFF1B7F5C),
    ),
    DashboardAlertItem(
      icon: Icons.view_kanban_outlined,
      title: 'Quadro de trabalho',
      subtitle: '4 itens no fluxo de trabalho',
      tone: Color(0xFF2F6F91),
    ),
    DashboardAlertItem(
      icon: Icons.assignment_outlined,
      title: 'Demandas do departamento',
      subtitle: '2 demandas registradas',
      tone: Color(0xFFB86724),
    ),
  ];

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
        name: 'Maria',
        email: 'maria.santos@ifma.edu.br',
        role: role,
        createdAt: DateTime.now(),
      ),
    );
    return userContext;
  }

  Future<void> pumpCard(
    WidgetTester tester, {
    required Size size,
    double textScale = 1,
  }) async {
    configureView(tester, size: size);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: DashboardAlertsCard(alerts: testAlerts),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard real usa card de avisos sem saudação', (tester) async {
    final userContext = await loggedInContext();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard-alerts-card')), findsOneWidget);
    expect(find.text('Atividades do departamento'), findsOneWidget);
    expect(find.text('Quadro de trabalho'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsOneWidget);
    expect(find.text('0 atividades registradas'), findsOneWidget);
    expect(find.text('0 itens no fluxo de trabalho'), findsOneWidget);
    expect(find.text('0 demandas registradas'), findsOneWidget);
    expect(find.text('Maria'), findsNothing);
    expect(find.text('Acesso rápido'), findsOneWidget);
    expect(find.byTooltip('Personalizar atalhos'), findsOneWidget);
    expect(find.text('Atenção agora'), findsOneWidget);
  });

  testWidgets('professor recebe resumo compatível com o perfil', (
    tester,
  ) async {
    final userContext = await loggedInContext(role: UserRole.professor);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acesso ao departamento'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsNothing);
  });

  testWidgets('card mantém densidade compacta em 390x844', (tester) async {
    await pumpCard(tester, size: const Size(390, 844));

    expect(find.text('Atividades do departamento'), findsOneWidget);
    expect(find.text('Quadro de trabalho'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsOneWidget);
    expect(find.text('Ver tudo'), findsOneWidget);

    final cardHeight = tester
        .getSize(find.byKey(const Key('dashboard-alerts-card')))
        .height;
    final rowHeights = [
      for (final title in [
        'Atividades do departamento',
        'Quadro de trabalho',
        'Demandas do departamento',
      ])
        tester.getSize(find.byKey(ValueKey('dashboard-alert-$title'))).height,
    ];
    final footerHeight = tester
        .getSize(find.byKey(const Key('dashboard-alerts-footer')))
        .height;
    expect(
      cardHeight,
      lessThanOrEqualTo(380),
      reason: 'linhas=$rowHeights, rodapé=$footerHeight',
    );

    await tester.tap(find.text('Atividades do departamento'));
    await tester.pumpAndSettle();
    expect(find.text('Fechar'), findsOneWidget);
  });

  testWidgets('não apresenta overflow em 320x568 com texto a 200%', (
    tester,
  ) async {
    await pumpCard(tester, size: const Size(320, 568), textScale: 2);

    expect(find.byKey(const Key('dashboard-alerts-card')), findsOneWidget);
    expect(find.text('Atividades do departamento'), findsOneWidget);
    expect(find.text('Quadro de trabalho'), findsOneWidget);
    expect(find.text('Demandas do departamento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
