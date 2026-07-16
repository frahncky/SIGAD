import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renderiza dashboard por perfil com foco', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord_1',
        name: 'Maria',
        email: 'maria.santos@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Olá, Maria'), findsOneWidget);
    expect(find.text('Atalhos do seu perfil'), findsOneWidget);
    expect(find.text('Prioridades'), findsNothing);
    expect(find.text('Demandas'), findsWidgets);
  });

  testWidgets('listas vazias não são substituídas por fixtures', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'sigad_demandas': '[]',
      'sigad_kanban': '[]',
      'sigad_atividades': '[]',
    });
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'prof_empty',
        name: 'Professor',
        email: 'professor@sigad.dev',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChangeNotifierProvider<UserContextProvider>.value(
          value: userContext,
          child: const Scaffold(body: DashboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma atividade aberta.'), findsOneWidget);
    expect(find.text('0% do quadro concluído'), findsOneWidget);
    expect(find.text('Entrega de levantamento de demandas'), findsNothing);

    await userContext.login(
      User(
        id: 'coord_empty',
        name: 'Coordenação',
        email: 'coordenacao@sigad.dev',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma demanda aberta.'), findsOneWidget);
    expect(find.text('Revisar inventário de microscópios'), findsNothing);
  });
}
