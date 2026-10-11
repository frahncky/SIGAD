import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';

Widget _buildShell({
  required UserContextProvider userContext,
  String route = AppRoutes.dashboard,
  double textScale = 1,
}) {
  final shell = HomeShellPage(
    currentRoute: route,
    child: const SizedBox.expand(child: Center(child: Text('Conteúdo'))),
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

  testWidgets('dashboard mobile mantém menu, perfil e remove notificações', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u1',
        name: 'Pedro',
        email: 'pedro@ifma.edu.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, 52);
  });

  testWidgets('outra rota mobile preserva notificações e perfil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u-other-route',
        name: 'Pedro',
        email: 'pedro@ifma.edu.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      _buildShell(userContext: userContext, route: AppRoutes.calendario),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    expect(tester.widget<AppBar>(find.byType(AppBar)).toolbarHeight, 64);
  });

  testWidgets('desktop exibe modulos permitidos para coordenador', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u2',
        name: 'Ana',
        email: 'ana@ifma.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Conteúdo'), findsOneWidget);
    expect(find.text('Demandas'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('drawer mobile exibe modulos permitidos para coordenador', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u-drawer',
        name: 'Marina',
        email: 'marina@ifma.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Demandas'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('exibe BottomNavigationBar em mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u3',
        name: 'Lucas',
        email: 'lucas@ifma.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
    expect(find.text('Visão geral'), findsOneWidget);
    expect(find.text('Calendário'), findsOneWidget);
    expect(find.text('Anotações'), findsOneWidget);
    expect(find.text('Mais'), findsNothing);
  });

  testWidgets(
    'rota secundária mantém atalhos sem destacar falsamente a visão geral',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final userContext = UserContextProvider();
      await userContext.login(
        User(
          id: 'u-secondary-route',
          name: 'Marina',
          email: 'marina@ifma.edu.br',
          role: UserRole.coordenador,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        _buildShell(
          userContext: userContext,
          route: AppRoutes.demandas,
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDestination), findsNothing);
      expect(find.text('Visão geral'), findsOneWidget);
      expect(find.text('Calendário'), findsOneWidget);
      expect(find.text('Anotações'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('notificações são apresentadas em lista rolável', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u-notifications',
        name: 'Marina',
        email: 'marina@ifma.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      _buildShell(userContext: userContext, route: AppRoutes.calendario),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notificações'));
    await tester.pumpAndSettle();

    expect(find.text('Notificações'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ListView),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
