import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/relatorios/domain/relatorios_service.dart';
import 'package:sigad/features/relatorios/presentation/pages/relatorios_page.dart';
import 'package:sigad/features/relatorios/presentation/relatorios_l10n.dart';
import 'package:sigad/l10n/l10n.dart';

Future<void> _pump(
  WidgetTester tester,
  UserRole role,
  Locale locale, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final userContext = UserContextProvider();
  await userContext.login(
    User(
      id: 'relatorios-teste',
      name: 'Usuário Teste',
      email: 'teste@exemplo.edu.br',
      role: role,
      createdAt: DateTime(2026),
    ),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<UserContextProvider>.value(
      value: userContext,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const RelatoriosPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('status e tipos de relatório têm tradução', () {
    final en = lookupAppLocalizations(const Locale('en'));
    for (final relatorio in RelatoriosService.defaultRelatorios()) {
      expect(en.opcaoRelatorio(relatorio.tipo), isNot(relatorio.tipo));
      expect(en.opcaoRelatorio(relatorio.status), isNot(relatorio.status));
    }
    for (final status in [
      ...RelatoriosService.statusDisponiveis,
      'Disponível',
      'PDF baixado agora',
      'Compartilhado agora',
    ]) {
      expect(en.opcaoRelatorio(status), isNot(status), reason: status);
    }
  });

  testWidgets('relatórios em português e inglês', (tester) async {
    await _pump(tester, UserRole.coordenador, const Locale('pt'));
    expect(find.text('Central de relatórios'), findsOneWidget);

    await _pump(tester, UserRole.coordenador, const Locale('en'));
    expect(find.text('Reports center'), findsOneWidget);
    expect(find.text('Published'), findsWidgets);
    expect(find.text('Human Resources'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('acesso negado em inglês', (tester) async {
    await _pump(tester, UserRole.professor, const Locale('en'));
    expect(find.text('Access not allowed for this profile.'), findsOneWidget);
  });

  testWidgets('relatórios em inglês com 320x568 e texto 200%', (tester) async {
    await _pump(
      tester,
      UserRole.coordenador,
      const Locale('en'),
      size: const Size(320, 568),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Human Resources'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
