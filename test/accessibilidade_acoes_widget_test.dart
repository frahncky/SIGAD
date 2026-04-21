import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/chat_provider.dart';
import 'package:sigad/core/services/theme_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/atividades/presentation/pages/atividades_page.dart';
import 'package:sigad/features/bate_papo/presentation/pages/bate_papo_page.dart';
import 'package:sigad/features/carga_docente/presentation/pages/carga_docente_page.dart';
import 'package:sigad/features/configuracoes/presentation/pages/configuracoes_page.dart';
import 'package:sigad/features/demandas/presentation/pages/demandas_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Demandas expõe tooltips nas ações principais', (tester) async {
    final userContext = UserContextProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: DemandasPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Abrir filtros'), findsOneWidget);
    expect(find.byTooltip('Criar nova demanda'), findsOneWidget);
  });

  testWidgets('Bate-papo expõe tooltip para limpar busca', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'user_email_joao.silva@univ.br',
        name: 'João Silva',
        email: 'joao.silva@univ.br',
        role: UserRole.professor,
        createdAt: DateTime.now(),
      ),
    );

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: BatePapoPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Maria');
    await tester.pumpAndSettle();

    expect(find.byTooltip('Limpar busca'), findsOneWidget);
    expect(find.byTooltip('Nova conversa'), findsOneWidget);
  });

  testWidgets('Configurações expõe tooltip de fechar no modal de perfil', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'cfg-chefe-a11y',
        name: 'Chefia',
        email: 'chefia@sigad.dev',
        role: UserRole.chefeDepartamento,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ConfiguracoesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Fechar edição de perfil'), findsOneWidget);
  });

  testWidgets('Atividades expõe tooltip na ação de criar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AtividadesPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Criar nova atividade'), findsOneWidget);
  });

  testWidgets('Carga Docente expõe tooltips nas ações principais', (tester) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord-carga-a11y',
        name: 'Coordenadora',
        email: 'maria.santos@univ.br',
        role: UserRole.coordenador,
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UserContextProvider>.value(
        value: userContext,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: CargaDocentePage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('Adicionar docente'), findsOneWidget);
    expect(find.byTooltip('Mais ações do docente').first, findsOneWidget);
  });
}
