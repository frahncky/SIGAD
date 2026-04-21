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
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: HomeShellPage(
        currentRoute: route,
        child: const SizedBox.expand(child: Center(child: Text('Conteúdo'))),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe AppBar em mobile com titulo correto', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u1',
        name: 'Pedro',
        email: 'pedro@univ.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });

  testWidgets('exibe side nav em desktop', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'u2',
        name: 'Ana',
        email: 'ana@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Conteúdo'), findsOneWidget);
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
        email: 'lucas@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(_buildShell(userContext: userContext));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
