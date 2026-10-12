import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/locale_provider.dart';
import 'package:sigad/core/services/theme_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/configuracoes/presentation/pages/configuracoes_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ThemeProvider> abrir(
    WidgetTester tester, {
    UserRole perfil = UserRole.professor,
    Size tamanho = const Size(412, 915),
    double escala = 1,
  }) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'cfg-${perfil.name}',
        name: 'Maria Souza',
        email: 'maria.souza@ifma.edu.br',
        role: perfil,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    final tema = ThemeProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider<ThemeProvider>.value(value: tema),
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: const ConfiguracoesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tema;
  }

  testWidgets('mostra os dados reais da conta, agrupados', (tester) async {
    await abrir(tester);

    expect(find.text('Minha conta'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);
    expect(find.text('maria.souza@ifma.edu.br'), findsOneWidget);
    expect(find.text(UserRole.professor.displayName), findsOneWidget);
    expect(find.text('Aparência e leitura'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
  });

  testWidgets('não exibe opções sem funcionalidade', (tester) async {
    await abrir(tester, perfil: UserRole.chefeDepartamento);

    for (final texto in [
      'Senha',
      'Notificações',
      'Autenticação biométrica',
      'Backup automático',
      'Política de privacidade',
      'Termos de serviço',
      'Reportar problema',
      'Lembrete da próxima disciplina',
    ]) {
      expect(find.text(texto), findsNothing, reason: texto);
    }
  });

  testWidgets('tamanho do texto muda o app e fica salvo', (tester) async {
    final tema = await abrir(tester);
    expect(tema.tamanhoTexto, ThemeProvider.tamanhoPadrao);

    await tester.tap(find.text(ThemeProvider.tamanhoPadrao));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grande').last);
    await tester.pumpAndSettle();

    expect(tema.tamanhoTexto, 'Grande');
    expect(tema.fatorTexto, 1.25);
    final prefs = await SharedPreferences.getInstance();
    final salvo =
        jsonDecode(prefs.getString('sigad_configuracoes')!)
            as Map<String, dynamic>;
    expect(salvo['tamanhoFonte'], 'Grande');
  });

  testWidgets('mural aparece só para a chefia', (tester) async {
    await abrir(tester);
    expect(find.text('Mural do departamento'), findsNothing);

    await abrir(tester, perfil: UserRole.chefeDepartamento);
    expect(find.text('Mural do departamento'), findsOneWidget);
  });

  testWidgets('configuracoes nao exibe agenda de compromissos', (tester) async {
    SharedPreferences.setMockInitialValues({
      'sigad_configuracoes': jsonEncode({
        'agendaCompromissos': [
          {
            'id': 'conv1',
            'titulo': 'Reunião de coordenação',
            'descricao': 'Planejamento semanal',
            'inicio': 'Hoje, 16:30',
            'inicioIso': DateTime.now()
                .add(const Duration(minutes: 20))
                .toIso8601String(),
            'local': 'Sala A',
            'origem': 'Convite de reunião',
            'destinatarioUserId': 'cfg-professor',
            'statusConvite': 'pendente',
          },
        ],
      }),
    });
    await abrir(tester);

    expect(find.text('Agenda de compromissos'), findsNothing);
    expect(find.textContaining('Reunião de coordenação'), findsNothing);
  });

  testWidgets(
    'sobre o SIGAD não apresenta overflow em tela pequena com texto ampliado',
    (tester) async {
      await abrir(
        tester,
        perfil: UserRole.coordenador,
        tamanho: const Size(320, 568),
        escala: 2,
      );

      final aboutEntry = find.text('Sobre o SIGAD');
      await tester.scrollUntilVisible(
        aboutEntry,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(aboutEntry);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Fechar sobre o SIGAD'), findsOneWidget);

      final closeButton = find.widgetWithText(ElevatedButton, 'Fechar');
      expect(closeButton.hitTestable(), findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Fechar sobre o SIGAD'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('trocar o idioma para English traduz a tela e fica salvo', (
    tester,
  ) async {
    await abrir(tester);
    await tester.scrollUntilVisible(
      find.text('Automático (idioma do celular)'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Automático (idioma do celular)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final salvo =
        jsonDecode(prefs.getString('sigad_configuracoes')!)
            as Map<String, dynamic>;
    expect(salvo['idioma'], 'English');
  });
}
