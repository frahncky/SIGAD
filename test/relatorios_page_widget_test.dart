import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/relatorios/presentation/pages/relatorios_page.dart';

Widget _buildApp(UserContextProvider userContext) {
  return ChangeNotifierProvider<UserContextProvider>.value(
    value: userContext,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const RelatoriosPage(),
    ),
  );
}

Future<UserContextProvider> _loggedIn(UserRole role) async {
  final ctx = UserContextProvider();
  await ctx.login(
    User(
      id: 'rel_user',
      name: 'Relatório Teste',
      email: 'rel@univ.br',
      role: role,
      createdAt: DateTime.now(),
    ),
  );
  return ctx;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('coordenador ve lista de relatorios', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('relatorios'), findsWidgets);
  });

  testWidgets('aluno nao tem acesso a relatorios', (tester) async {
    final ctx = await _loggedIn(UserRole.aluno);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    expect(find.textContaining('permissão'), findsWidgets);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('filtro de status funciona', (tester) async {
    final ctx = await _loggedIn(UserRole.coordenador);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    final chips = find.byType(FilterChip);
    expect(chips, findsWidgets);

    await tester.tap(chips.at(1));
    await tester.pumpAndSettle();
  });

  testWidgets('busca filtra relatorios por titulo', (tester) async {
    final ctx = await _loggedIn(UserRole.chefeDepartamento);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'xxxxxxxxxxx');
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum relatorio encontrado'), findsOneWidget);
  });

  testWidgets('empty state exibido quando busca nao tem resultado', (tester) async {
    final ctx = await _loggedIn(UserRole.servidorAdministrativo);

    await tester.pumpWidget(_buildApp(ctx));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'busca_sem_resultado_99999');
    await tester.pumpAndSettle();

    expect(find.textContaining('Nenhum relatorio'), findsOneWidget);
  });
}
