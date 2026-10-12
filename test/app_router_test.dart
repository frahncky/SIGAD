import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_router.dart';
import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';
import 'package:sigad/features/redesign/presentation/pages/module_workspace_page.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('rota de módulo sem sessão mostra login e não monta os dados', (
    tester,
  ) async {
    final userContext = UserContextProvider();
    addTearDown(userContext.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        child: MaterialApp(
          initialRoute: AppRoutes.dashboard,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(DashboardPage), findsNothing);
    expect(find.byType(ModuleWorkspacePage), findsNothing);
  });
  testWidgets('dashboard exibe operação e reserva visão gerencial', (
    tester,
  ) async {
    final userContext = UserContextProvider();
    addTearDown(userContext.dispose);
    await userContext.login(
      User(
        id: 'coordenador-1',
        name: 'Maria',
        email: 'maria@exemplo.edu.br',
        role: UserRole.coordenador,
        createdAt: DateTime(2026),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MaterialApp(
          initialRoute: AppRoutes.dashboard,
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final workspace = tester.widget<ModuleWorkspacePage>(
      find.byType(ModuleWorkspacePage),
    );
    expect(workspace.overview, isA<SigadDashboardPage>());
    expect(workspace.operation, isA<DashboardPage>());
    expect(workspace.operationLabel, 'Painel operacional');
    expect(find.byType(DashboardPage), findsOneWidget);

    await userContext.logout();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(DashboardPage), findsNothing);
    expect(find.byType(ModuleWorkspacePage), findsNothing);
  });
}
