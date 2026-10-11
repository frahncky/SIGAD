import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/auth_session_repository.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/redesign/presentation/pages/sigad_redesign_pages.dart';

final _saudacao = RegExp(r'^(Bom dia|Boa tarde|Boa noite)');

Widget _app() {
  const page = Scaffold(body: SigadDashboardPage());
  return MaterialApp(
    theme: AppTheme.light(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(2)),
      child: child!,
    ),
    home: page,
  );
}

void _telaPequena(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sem avisos mostra apenas o card de boas-vindas', (tester) async {
    _telaPequena(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.textContaining(_saudacao), findsOneWidget);
    expect(find.textContaining('IFMA Campus Monte Castelo'), findsOneWidget);
    expect(find.text('Ver todos os avisos'), findsNothing);
    expect(find.bySemanticsLabel('Mostrar Avisos'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com avisos alterna entre boas-vindas e avisos', (tester) async {
    _telaPequena(tester);
    final userContext = UserContextProvider(
      sessionRepository: AuthSessionRepository(storageKey: 'hero_test'),
    );
    await userContext.login(
      User(
        id: 'c1',
        name: 'Ana Souza',
        email: 'ana@sigad.dev',
        role: UserRole.coordenador,
        createdAt: DateTime(2026),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: userContext, child: _app()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(RegExp(r', Ana!$')), findsOneWidget);
    expect(find.text('Ver todos os avisos'), findsNothing);

    // Rotação automática.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Ver todos os avisos'), findsOneWidget);
    expect(find.text('2 demandas aguardam revisão'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver todos os avisos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todos os avisos'));
    await tester.pumpAndSettle();
    expect(find.text('Fechar'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.bySemanticsLabel('Mostrar Boas-vindas'));
    await tester.tap(find.bySemanticsLabel('Mostrar Boas-vindas'));
    await tester.pumpAndSettle();
    expect(find.textContaining(RegExp(r', Ana!$')), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, skip: !AppRuntimeConfig.allowLocalDemo);
}
