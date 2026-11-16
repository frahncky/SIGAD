import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';

Widget _buildShell({
  required UserContextProvider userContext,
  String route = AppRoutes.dashboard,
  double textScale = 1,
  Widget? child,
}) {
  final shell = HomeShellPage(
    currentRoute: route,
    child:
        child ?? const SizedBox.expand(child: Center(child: Text('Conteúdo'))),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: shell,
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<UserContextProvider> login(
    String id, {
    UserRole role = UserRole.coordenador,
  }) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: id,
        name: 'Marina',
        email: 'marina@exemplo.edu.br',
        role: role,
        createdAt: DateTime.now(),
      ),
    );
    return userContext;
  }

  void configureView(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  final bottomBar = find.byKey(const ValueKey('sigad-bottom-bar'));

  testWidgets('dashboard mobile usa o topo da página, sem AppBar', (
    tester,
  ) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u1', role: UserRole.professor);

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(bottomBar, findsOneWidget);
    expect(find.text('Conteúdo'), findsOneWidget);
  });

  testWidgets('outra rota mobile mantém menu, notificações e perfil', (
    tester,
  ) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u-other-route', role: UserRole.professor);

    await tester.pumpWidget(
      _buildShell(userContext: userContext, route: AppRoutes.calendario),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(SigadIcons.menu), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, 64);
    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(
      find.descendant(
        of: bottomBar,
        matching: find.byIcon(SigadIcons.notificacao),
      ),
      findsNothing,
    );
  });

  testWidgets('desktop exibe modulos permitidos para coordenador', (
    tester,
  ) async {
    configureView(tester, const Size(1280, 900));
    final userContext = await login('u2');

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(bottomBar, findsNothing);
    expect(find.text('Conteúdo'), findsOneWidget);
    expect(find.text('Demandas'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('drawer mobile exibe modulos permitidos para coordenador', (
    tester,
  ) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u-drawer');

    await tester.pumpWidget(
      _buildShell(userContext: userContext, route: AppRoutes.calendario),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Demandas'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('barra inferior mantém Visão geral, Calendário e Anotações', (
    tester,
  ) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u3');

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    for (final rotulo in ['Visão geral', 'Calendário', 'Anotações']) {
      expect(
        find.descendant(of: bottomBar, matching: find.text(rotulo)),
        findsOneWidget,
        reason: rotulo,
      );
    }
    expect(find.text('Mais'), findsNothing);
    expect(find.byIcon(SigadIcons.adicionar), findsNothing);

    final visaoGeral = tester.getSemantics(
      find.descendant(
        of: bottomBar,
        matching: find.bySemanticsLabel('Visão geral'),
      ),
    );
    expect(
      visaoGeral,
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
  });

  for (final size in const [
    Size(320, 568),
    Size(360, 640),
    Size(568, 320),
    Size(412, 915),
  ]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets(
        'rota secundária sem overflow ${size.width}x${size.height} $scale',
        (tester) async {
          configureView(tester, size);
          final userContext = await login('u-secondary-route');

          await tester.pumpWidget(
            _buildShell(
              userContext: userContext,
              route: AppRoutes.demandas,
              textScale: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(bottomBar, findsOneWidget);
          final visaoGeral = tester.getSemantics(
            find.descendant(
              of: bottomBar,
              matching: find.bySemanticsLabel('Visão geral'),
            ),
          );
          expect(visaoGeral, isSemantics(isSelected: false));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('notificações são apresentadas em lista rolável', (tester) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u-notifications');

    await tester.pumpWidget(
      _buildShell(userContext: userContext, route: AppRoutes.calendario),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notificações'));
    await tester.pumpAndSettle();

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Nenhuma notificação no momento.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Visão geral mobile abre o menu lateral pelo topo', (
    tester,
  ) async {
    configureView(tester, const Size(390, 844));
    final userContext = await login('u-menu-dashboard');

    await tester.pumpWidget(
      _buildShell(
        userContext: userContext,
        child: DashboardPage(agora: DateTime(2026, 11, 12, 7, 33)),
      ),
    );
    await tester.pumpAndSettle();

    final menu = find.byKey(const Key('overview-menu'));
    expect(menu, findsOneWidget);
    expect(tester.getSize(menu), const Size(48, 48));
    await tester.tap(menu);
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Relatórios'), findsWidgets);
  });
}
