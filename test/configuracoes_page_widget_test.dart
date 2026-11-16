import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/locale_provider.dart';
import 'package:sigad/core/services/theme_provider.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/core/services/greeting_name_provider.dart';
import 'package:sigad/features/configuracoes/data/agenda_convites_service.dart';
import 'package:sigad/features/configuracoes/data/configuracoes_repository.dart';
import 'package:sigad/features/configuracoes/domain/app_versao.dart';
import 'package:sigad/features/configuracoes/presentation/pages/configuracoes_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ConfiguracoesRepository.limparFilas();
  });

  Future<ThemeProvider> abrir(
    WidgetTester tester, {
    UserRole perfil = UserRole.professor,
    Size tamanho = const Size(412, 915),
    double escala = 1,
    ThemeProvider? temaInicial,
    bool escuro = false,
    String? versao,
    bool aguardar = true,
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
    final tema = temaInicial ?? ThemeProvider();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserContextProvider>.value(value: userContext),
          ChangeNotifierProvider(
            create: (_) => GreetingNameProvider(userContext),
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: tema),
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
        ],
        child: MaterialApp(
          theme: escuro ? AppTheme.dark() : AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: Scaffold(body: ConfiguracoesPage(versao: versao)),
        ),
      ),
    );
    if (aguardar) await tester.pumpAndSettle();
    return tema;
  }

  testWidgets('nome na saudação salva, cancela e restaura fallback', (
    tester,
  ) async {
    await abrir(tester, tamanho: const Size(320, 568), escala: 2);
    // Em 320x568 a 200% o aviso de "salvo" cobre a linha por alguns
    // segundos; o teste o dispensa antes de tocar de novo.
    Future<void> dispensarAviso() async {
      ScaffoldMessenger.of(
        tester.element(find.byType(ConfiguracoesPage)),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Nome na saudação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Maria Clara Souza');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Maria Clara Souza'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);
    await dispensarAviso();
    await tester.tap(find.text('Nome na saudação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Outro nome');
    await tester.ensureVisible(find.text('Cancelar'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Maria Clara Souza'), findsOneWidget);
    await tester.tap(find.text('Nome na saudação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Maria'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  Future<Map<String, dynamic>> salvo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sigad_configuracoes');
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  Map<String, dynamic> convite(String id) => {
    'id': id,
    'titulo': 'Reunião $id',
    'descricao': 'Pauta',
    'inicio': 'Hoje, 16:30',
    'inicioIso': DateTime(2026, 11, 20, 16, 30).toIso8601String(),
    'local': 'Sala A',
    'origem': 'Convite de reunião',
    'destinatarioUserId': 'cfg-professor',
    'statusConvite': 'pendente',
  };

  group('C1 — preferências não apagam convites', () {
    testWidgets('alterar o modo noturno logo ao abrir preserva convites', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'sigad_configuracoes': jsonEncode({
          'tamanhoFonte': 'Grande',
          'agendaCompromissos': [convite('c1'), convite('c2')],
        }),
      });
      // Sem aguardar a tela "assentar": a alteração acontece no primeiro
      // quadro, quando antes o estado da página ainda era o padrão.
      await abrir(tester, aguardar: false);
      await tester.pump();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final dados = await salvo();
      expect(dados['modoDark'], isTrue);
      expect(dados['tamanhoFonte'], 'Grande');
      expect(dados['agendaCompromissos'], hasLength(2));
    });

    testWidgets('alterar preferência enquanto um convite é gravado', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'sigad_configuracoes': jsonEncode({
          'agendaCompromissos': [convite('c1')],
        }),
      });
      await abrir(tester);

      final gravacao = AgendaConvitesService.registrarConviteRecebido(
        destinatarioUserId: 'cfg-professor',
        titulo: 'Novo convite',
        descricao: 'Recebido com a tela aberta',
        inicio: 'Amanhã, 10:00',
        local: 'Sala B',
      );
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await gravacao;

      final dados = await salvo();
      expect(dados['modoDark'], isTrue);
      final titulos = (dados['agendaCompromissos'] as List)
          .map((item) => (item as Map)['titulo'])
          .toList();
      expect(titulos, ['Reunião c1', 'Novo convite']);
    });

    testWidgets('não grava dados demonstrativos que a tela não exibe', (
      tester,
    ) async {
      await abrir(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final dados = await salvo();
      expect(dados, {'modoDark': true});
    });
  });

  group('modo noturno', () {
    testWidgets('o switch reflete o ThemeProvider', (tester) async {
      final tema = await abrir(
        tester,
        temaInicial: ThemeProvider(isDark: true),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      tema.setDark(false);
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

      await tester.tap(find.text('Modo noturno'));
      await tester.pumpAndSettle();
      expect(tema.isDark, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect((await salvo())['modoDark'], isTrue);
    });
  });

  group('sobre', () {
    testWidgets('não mostra dados inventados e usa a versão da compilação', (
      tester,
    ) async {
      await abrir(tester, versao: '1.0.0 (1)');
      expect(find.text('Versão 1.0.0 (1)'), findsOneWidget);

      await tester.tap(find.text('Sobre o SIGAD'));
      await tester.pumpAndSettle();

      expect(find.text('1.0.0 (1)'), findsOneWidget);
      for (final texto in [
        'Build 42',
        '15/03/2026',
        'Android 8.0+',
        'iOS 12.0+',
        'Data de lançamento',
        'Compatibilidade',
      ]) {
        expect(find.textContaining(texto), findsNothing, reason: texto);
      }
      // Ativo oficial em vez do quadrado improvisado "SIGAD".
      expect(find.text('SIGAD'), findsNothing);
      final imagem = tester.widget<Image>(find.byType(Image));
      expect(
        (imagem.image as AssetImage).assetName,
        'assets/images/app_icon.png',
      );
    });

    test('formata a versão somente com dados da compilação', () {
      expect(AppVersao.formatar(nome: '1.0.0', numero: '1'), '1.0.0 (1)');
      expect(AppVersao.formatar(nome: '1.0.0'), '1.0.0');
      expect(AppVersao.formatar(nome: '1.0.0', numero: ' '), '1.0.0');
      expect(AppVersao.formatar(), isNull);
      expect(AppVersao.formatar(nome: '', numero: '1'), isNull);
    });
  });

  group('conta e ações', () {
    testWidgets('bloco da conta, editar saudação e sair em contorno', (
      tester,
    ) async {
      await abrir(tester);

      final saudacao = find.widgetWithText(ListTile, 'Nome na saudação');
      expect(
        find.descendant(of: saudacao, matching: find.byIcon(SigadIcons.editar)),
        findsWidgets,
      );
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(find.text('Nome'), findsNothing);
      expect(find.text('Perfil de acesso'), findsNothing);

      final sair = find.widgetWithText(OutlinedButton, 'Sair da conta');
      expect(sair, findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sair da conta'), findsNothing);
      expect(tester.getSize(sair).height, greaterThanOrEqualTo(52));
    });

    testWidgets('seletor anuncia a opção atual e abre opções de rádio', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await abrir(tester);

      expect(
        find.bySemanticsLabel(RegExp(r'Tamanho do texto[\s\S]*Médio')),
        findsOneWidget,
      );
      await tester.tap(find.text('Tamanho do texto'));
      await tester.pumpAndSettle();

      final opcoes = find.byType(RadioListTile<String>);
      expect(opcoes, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        expect(
          tester.getSize(opcoes.at(i)).height,
          greaterThanOrEqualTo(48),
        );
      }
      semantics.dispose();
    });
  });

  group('matriz sem overflow', () {
    const tamanhos = [
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(412, 915),
      Size(568, 320),
    ];
    const escalas = [1.0, 1.5, 2.0];

    for (final tamanho in tamanhos) {
      for (final escala in escalas) {
        testWidgets('$tamanho a ${(escala * 100).round()}%', (tester) async {
          await abrir(
            tester,
            perfil: UserRole.chefeDepartamento,
            tamanho: tamanho,
            escala: escala,
            versao: '1.0.0 (1)',
          );
          expect(tester.takeException(), isNull);
          await tester.scrollUntilVisible(
            find.text('Sair da conta'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    for (final tamanho in const [Size(320, 568), Size(568, 320)]) {
      testWidgets('sheets em $tamanho a 200%', (tester) async {
        await abrir(tester, tamanho: tamanho, escala: 2, versao: '1.0.0 (1)');
        for (final entrada in ['Sobre o SIGAD', 'Tamanho do texto', 'Idioma']) {
          final item = find.text(entrada);
          await tester.scrollUntilVisible(
            item,
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(item);
          await tester.pumpAndSettle();
          await tester.tap(item);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: entrada);
          expect(find.byType(BottomSheet), findsOneWidget, reason: entrada);
          Navigator.of(tester.element(find.byType(BottomSheet))).pop();
          await tester.pumpAndSettle();
          expect(find.byType(BottomSheet), findsNothing, reason: entrada);
        }
      });
    }

    for (final escuro in [false, true]) {
      testWidgets('390x844 tema ${escuro ? 'escuro' : 'claro'}', (
        tester,
      ) async {
        await abrir(
          tester,
          tamanho: const Size(390, 844),
          escuro: escuro,
          perfil: UserRole.chefeDepartamento,
        );
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Sair da conta'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Sair da conta'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
