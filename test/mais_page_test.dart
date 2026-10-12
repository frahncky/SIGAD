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
import 'package:sigad/l10n/l10n.dart';

Future<void> _pumpMais(WidgetTester tester, Locale locale) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final userContext = UserContextProvider();
  await userContext.login(
    User(
      id: 'mais-professor',
      name: 'Professor Teste',
      email: 'professor@exemplo.edu.br',
      role: UserRole.professor,
      createdAt: DateTime(2026),
    ),
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userContext),
        ChangeNotifierProvider(create: (_) => MuralController()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: MaisPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('tela Mais em português', (tester) async {
    await _pumpMais(tester, const Locale('pt'));

    expect(find.text('Avisos importantes'), findsOneWidget);
    expect(find.text('Acesso rápido'), findsOneWidget);
    expect(find.text('Reuniões'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tela Mais em inglês', (tester) async {
    await _pumpMais(tester, const Locale('en'));

    expect(find.text('Important notices'), findsOneWidget);
    expect(find.text('No notices right now.'), findsOneWidget);
    expect(find.text('Quick access'), findsOneWidget);
    expect(find.text('Meetings'), findsOneWidget);

    await tester.ensureVisible(find.text('Help'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Help center'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
