import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/app.dart';
import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/features/demandas/presentation/pages/demandas_page.dart';
import 'package:sigad/features/home/presentation/pages/home_shell_page.dart';
import 'package:sigad/features/login/presentation/pages/login_page.dart';
import 'package:sigad/features/relatorios/presentation/pages/relatorios_page.dart';

User _userFor(UserRole role) {
  return User(
    id: 'guard-${role.name}',
    name: 'Usuário ${role.displayName}',
    email: '${role.name}@sigad.test',
    role: role,
    createdAt: DateTime(2026, 1, 1),
  );
}

Future<UserContextProvider> _authenticatedAs(UserRole role) async {
  final userContext = UserContextProvider();
  await userContext.login(
    _userFor(role),
    sessionToken: 'guard-token-${role.name}',
  );
  return userContext;
}

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String route,
  required UserContextProvider userContext,
}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    SigadApp(initialRoute: route, userContextProvider: userContext),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppRouter guard central', () {
    testWidgets('acesso direto sem autenticação exibe Login', (tester) async {
      final userContext = UserContextProvider();
      await userContext.restoreSession();

      await _pumpRoute(
        tester,
        route: AppRoutes.relatorios,
        userContext: userContext,
      );

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomeShellPage), findsNothing);
      expect(find.byType(RelatoriosPage), findsNothing);
    });

    testWidgets('professor é bloqueado em Demandas', (tester) async {
      final userContext = await _authenticatedAs(UserRole.professor);

      await _pumpRoute(
        tester,
        route: AppRoutes.demandas,
        userContext: userContext,
      );

      expect(find.text('Acesso não autorizado'), findsOneWidget);
      expect(find.byType(DemandasPage), findsNothing);
    });

    testWidgets('administrativo é bloqueado em Carga docente', (tester) async {
      final userContext = await _authenticatedAs(
        UserRole.servidorAdministrativo,
      );

      await _pumpRoute(
        tester,
        route: AppRoutes.cargaDocente,
        userContext: userContext,
      );

      expect(find.text('Acesso não autorizado'), findsOneWidget);
      expect(find.byType(CargaDocentePage), findsNothing);
    });

    testWidgets('administrativo pode acessar Relatórios', (tester) async {
      final userContext = await _authenticatedAs(
        UserRole.servidorAdministrativo,
      );

      await _pumpRoute(
        tester,
        route: AppRoutes.relatorios,
        userContext: userContext,
      );

      expect(find.byType(RelatoriosPage), findsOneWidget);
      expect(find.text('Acesso não autorizado'), findsNothing);
    });

    testWidgets('professor pode acessar Carga docente', (tester) async {
      final userContext = await _authenticatedAs(UserRole.professor);

      await _pumpRoute(
        tester,
        route: AppRoutes.cargaDocente,
        userContext: userContext,
      );

      expect(find.byType(CargaDocentePage), findsOneWidget);
      expect(find.text('Acesso não autorizado'), findsNothing);
    });

    testWidgets('alias /professores segue a rota canônica de Carga docente', (
      tester,
    ) async {
      final userContext = await _authenticatedAs(UserRole.professor);

      await _pumpRoute(
        tester,
        route: AppRoutes.professores,
        userContext: userContext,
      );

      final cargaFinder = find.byType(CargaDocentePage);
      expect(cargaFinder, findsOneWidget);
      expect(
        ModalRoute.of(tester.element(cargaFinder))?.settings.name,
        AppRoutes.cargaDocente,
      );
    });

    testWidgets('logout reavalia a rota protegida e exibe Login', (
      tester,
    ) async {
      final userContext = await _authenticatedAs(
        UserRole.servidorAdministrativo,
      );

      await _pumpRoute(
        tester,
        route: AppRoutes.relatorios,
        userContext: userContext,
      );
      expect(find.byType(RelatoriosPage), findsOneWidget);

      await userContext.logout();
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomeShellPage), findsNothing);
      expect(find.byType(RelatoriosPage), findsNothing);
    });
  });
}
