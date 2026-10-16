import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/routes/app_routes.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/navigation/navigation_items.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/features/mais/presentation/pages/mais_page.dart';
import 'package:sigad/features/mural/presentation/state/mural_controller.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';

Future<void> _pump(WidgetTester tester, UserRole role, Widget page) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final session = UserContextProvider();
  await session.login(
    User(
      id: 'visibility-test',
      name: 'Teste',
      email: 'teste@exemplo.edu.br',
      role: role,
      createdAt: DateTime(2026),
    ),
  );
  final mural = MuralController();
  addTearDown(session.dispose);
  addTearDown(mural.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider.value(value: mural),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: page),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final role in UserRole.values) {
    final allowed = role != UserRole.servidorAdministrativo;
    test('menu Carga docente respeita ${role.name}', () {
      final item = kNavigationItems.singleWhere(
        (item) => item.route == AppRoutes.cargaDocente,
      );
      expect(item.isAvailableFor(role), allowed);
    });
    testWidgets('atalhos de início respeitam ${role.name}', (tester) async {
      await _pump(tester, role, const SigadDashboardPage());
      expect(
        find.text('Carga docente'),
        allowed ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('atalhos de Mais respeitam ${role.name}', (tester) async {
      await _pump(tester, role, const MaisPage());
      expect(
        find.text('Carga docente'),
        allowed ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('administrativo continua bloqueado ao abrir Carga docente', (
    tester,
  ) async {
    await _pump(
      tester,
      UserRole.servidorAdministrativo,
      const CargaDocentePage(),
    );
    expect(
      find.text(
        'Somente docentes, coordenação e chefia podem acessar esta área.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Docente 01'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
