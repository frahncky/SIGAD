import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/aulas_praticas/data/laboratorio_repository.dart';
import 'package:sigad/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:sigad/features/mural/domain/mural_models.dart';
import 'package:sigad/features/mural/presentation/state/mural_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaboratorioRepository.limparCache();
  });

  // Quinta-feira, 12/11/2026, 07:33.
  final agora = DateTime(2026, 11, 12, 7, 33);

  void configureView(WidgetTester tester, {required Size size}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<UserContextProvider> loggedInContext({
    UserRole role = UserRole.coordenador,
  }) async {
    final userContext = UserContextProvider();
    await userContext.login(
      User(
        id: 'coord_1',
        name: 'Maria Santos',
        email: 'maria.santos@exemplo.edu.br',
        role: role,
        createdAt: DateTime.now(),
      ),
    );
    return userContext;
  }

  Future<void> pumpDashboard(
    WidgetTester tester, {
    UserRole role = UserRole.coordenador,
    Size size = const Size(390, 844),
    double textScale = 1,
    List<Aviso> avisos = const [],
    Map<String, Object> prefs = const {},
  }) async {
    if (prefs.isNotEmpty) SharedPreferences.setMockInitialValues(prefs);
    configureView(tester, size: size);
    final userContext = await loggedInContext(role: role);
    final mural = MuralController();
    await mural.carregar();
    for (final aviso in avisos) {
      await mural.salvarAviso(aviso);
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<UserContextProvider>.value(
              value: userContext,
            ),
            ChangeNotifierProvider<MuralController>.value(value: mural),
          ],
          child: Scaffold(body: DashboardPage(agora: agora)),
        ),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(body: Text('rota ${settings.name}')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder indicador(String id) => find.byKey(ValueKey('indicador-$id'));

  Future<void> rolarAte(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  final avisoReuniao = Aviso(
    id: 'a1',
    modelo: ModeloAviso.evento,
    titulo: 'Reunião de colegiado',
    conteudo: 'Hoje, 14h, sala 305.',
    criadoEm: DateTime(2026),
  );

  testWidgets('topo identifica departamento e saudação, sem data', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.byKey(const Key('overview-header')), findsOneWidget);
    expect(find.byKey(const Key('welcome-hero')), findsNothing);
    expect(find.text('DEE · IFMA'), findsOneWidget);
    expect(find.text('Departamento de Eletroeletrônica'), findsOneWidget);
    expect(find.text('Bom dia, Maria!'), findsOneWidget);
    expect(find.text('Campus São Luís – Monte Castelo'), findsOneWidget);
    // A data já aparece no próprio celular.
    expect(find.textContaining('novembro'), findsNothing);
    // O botão de perfil mostra a inicial do usuário.
    expect(
      find.descendant(of: find.byTooltip('Perfil'), matching: find.text('M')),
      findsOneWidget,
    );
    expect(find.byTooltip('Notificações'), findsOneWidget);
    expect(find.byTooltip('Perfil'), findsOneWidget);
    expect(find.text('Acesso rápido'), findsOneWidget);
    expect(find.byTooltip('Personalizar atalhos'), findsOneWidget);
    expect(find.text('Pendências e prazos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coordenador vê os quatro indicadores com dados reais', (
    tester,
  ) async {
    await pumpDashboard(tester);

    for (final id in ['demandas', 'tarefas', 'atividades', 'laboratorios']) {
      expect(indicador(id), findsOneWidget, reason: id);
    }
    expect(
      find.descendant(of: indicador('demandas'), matching: find.text('0')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: indicador('demandas'),
        matching: find.text('Nenhuma prioritária'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('professor não vê o indicador de demandas', (tester) async {
    await pumpDashboard(tester, role: UserRole.professor);

    expect(indicador('demandas'), findsNothing);
    expect(indicador('laboratorios'), findsOneWidget);
    await rolarAte(tester, find.text('Nenhuma atividade aberta.'));
    expect(find.text('Nenhuma atividade aberta.'), findsOneWidget);
  });

  testWidgets('servidor administrativo vê apenas indicadores do seu perfil', (
    tester,
  ) async {
    await pumpDashboard(tester, role: UserRole.servidorAdministrativo);

    expect(indicador('demandas'), findsNothing);
    expect(indicador('laboratorios'), findsNothing);
    expect(indicador('tarefas'), findsOneWidget);
    expect(indicador('atividades'), findsOneWidget);
  });

  testWidgets('indicador abre o módulo correspondente', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(indicador('tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('rota /kanban'), findsOneWidget);
  });

  testWidgets('pendências mostram demandas por prazo com situação', (
    tester,
  ) async {
    Map<String, Object> demanda(String id, String titulo, String prazo) => {
      'id': id,
      'titulo': titulo,
      'descricao': '',
      'prioridade': 'Média',
      'statusLabel': 'Em andamento',
      'proprietario': 'Chefia do DEE',
      'prazo': prazo,
    };
    await pumpDashboard(
      tester,
      prefs: {
        'sigad_demandas': jsonEncode([
          demanda('#DEM-003', 'Relatório final', '30/11/2026'),
          demanda('#DEM-001', 'Indicação de servidor', '12/11/2026'),
          demanda('#DEM-002', 'Parecer atrasado', '01/11/2026'),
        ]),
      },
    );

    await rolarAte(tester, find.text('Relatório final'));
    final atrasada = tester.getTopLeft(find.text('Parecer atrasado')).dy;
    final hoje = tester.getTopLeft(find.text('Indicação de servidor')).dy;
    final depois = tester.getTopLeft(find.text('Relatório final')).dy;
    expect(atrasada, lessThan(hoje));
    expect(hoje, lessThan(depois));
    expect(find.text('Atrasada'), findsOneWidget);
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(
      find.text('Prazo: 12/11/2026 • Chefia do DEE • Prioridade média'),
      findsOneWidget,
    );
    expect(
      find.descendant(of: indicador('demandas'), matching: find.text('3')),
      findsOneWidget,
    );
  });

  testWidgets('sem avisos no mural não exibe o cartão de avisos', (
    tester,
  ) async {
    await pumpDashboard(tester);
    expect(find.byKey(const Key('dashboard-avisos')), findsNothing);
    expect(find.byKey(const ValueKey('slide-frase')), findsOneWidget);
    expect(find.byKey(const Key('overview-carrossel')), findsNothing);
  });

  final avisoProva = Aviso(
    id: 'a2',
    modelo: ModeloAviso.evento,
    titulo: 'Semana da elétrica',
    conteudo: 'Inscrições abertas até sexta.',
    criadoEm: DateTime(2026),
  );

  testWidgets('com avisos o card do topo gira entre eles, sem a frase', (
    tester,
  ) async {
    await pumpDashboard(tester, avisos: [avisoReuniao, avisoProva]);

    expect(find.byKey(const ValueKey('slide-frase')), findsNothing);
    final atual = find.descendant(
      of: find.byKey(const Key('dashboard-avisos')),
      matching: find.byType(Text),
    );
    String tituloVisivel() => tester.widget<Text>(atual.first).data!;
    final primeiro = tituloVisivel();

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    final segundo = tituloVisivel();
    expect(segundo, isNot(primeiro));

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(tituloVisivel(), primeiro);
  });

  testWidgets('card do topo troca de aviso ao deslizar', (tester) async {
    await pumpDashboard(tester, avisos: [avisoReuniao, avisoProva]);
    final atual = find.descendant(
      of: find.byKey(const Key('dashboard-avisos')),
      matching: find.byType(Text),
    );
    final antes = tester.widget<Text>(atual.first).data;

    await tester.fling(
      find.byKey(const Key('dashboard-avisos')),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(atual.first).data, isNot(antes));
  });

  testWidgets('leitor de tela troca de aviso pelos gestos de ajuste', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await pumpDashboard(tester, avisos: [avisoReuniao, avisoProva]);
    final card = find.byKey(const Key('dashboard-avisos'));
    final no = tester.getSemantics(card);
    expect(
      no,
      isSemantics(
        isButton: true,
        hasTapAction: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        value: '1/2',
      ),
    );
    no.owner!.performAction(no.id, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(card), isSemantics(value: '2/2'));
    semantica.dispose();
  });

  testWidgets('avisos do topo abrem a lista completa', (tester) async {
    await pumpDashboard(tester, avisos: [avisoReuniao]);

    expect(
      find.descendant(
        of: find.byKey(const Key('overview-header')),
        matching: find.byKey(const Key('dashboard-avisos')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('dashboard-avisos')));
    await tester.pumpAndSettle();
    expect(find.text('Hoje, 14h, sala 305.'), findsWidgets);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
  });

  for (final (nome, ajuste)
      in <(String, MediaQueryData Function(MediaQueryData))>[
        ('animações reduzidas', (m) => m.copyWith(disableAnimations: true)),
        ('leitor de tela', (m) => m.copyWith(accessibleNavigation: true)),
      ]) {
    testWidgets('com $nome o card do topo não gira sozinho', (tester) async {
      configureView(tester, size: const Size(390, 844));
      final userContext = await loggedInContext();
      final mural = MuralController();
      await mural.carregar();
      await mural.salvarAviso(avisoReuniao);
      await mural.salvarAviso(avisoProva);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) =>
              MediaQuery(data: ajuste(MediaQuery.of(context)), child: child!),
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<UserContextProvider>.value(
                value: userContext,
              ),
              ChangeNotifierProvider<MuralController>.value(value: mural),
            ],
            child: Scaffold(body: DashboardPage(agora: agora)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final atual = find.descendant(
        of: find.byKey(const Key('dashboard-avisos')),
        matching: find.byType(Text),
      );
      final antes = tester.widget<Text>(atual.first).data;
      await tester.pump(const Duration(seconds: 21));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(atual.first).data, antes);
    });
  }

  for (final role in [
    UserRole.coordenador,
    UserRole.professor,
    UserRole.servidorAdministrativo,
  ]) {
    for (final portrait in const [
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(412, 915),
    ]) {
      for (final landscape in [false, true]) {
        final size = landscape
            ? Size(portrait.height, portrait.width)
            : portrait;
        for (final scale in [1.0, 1.5, 2.0]) {
          testWidgets(
            'sem overflow ${role.name} ${size.width}x${size.height} $scale',
            (tester) async {
              await pumpDashboard(
                tester,
                role: role,
                size: size,
                textScale: scale,
                avisos: [avisoReuniao],
              );
              expect(tester.takeException(), isNull);
              await rolarAte(tester, find.text('Pendências e prazos'));
              await tester.drag(
                find.byType(Scrollable).first,
                const Offset(0, -2000),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }

  for (final scale in [2.2, 2.8]) {
    testWidgets('topo sem overflow com fonte $scale em 320x568', (
      tester,
    ) async {
      await pumpDashboard(
        tester,
        size: const Size(320, 568),
        textScale: scale,
        avisos: [avisoReuniao],
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('dashboard-avisos')), findsOneWidget);
      await rolarAte(tester, find.text('Pendências e prazos'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('atividades vencidas recebem o selo Atrasada', (tester) async {
    Map<String, Object> atividade(String id, String titulo, String data) => {
      'id': id,
      'titulo': titulo,
      'descricao': '',
      'data': data,
      'responsavel': 'Coordenação',
      'status': 'Agendada',
    };
    await pumpDashboard(
      tester,
      role: UserRole.professor,
      prefs: {
        'sigad_atividades': jsonEncode([
          atividade('a1', 'Banca de TCC', '10/11/2026 - 14:00'),
          atividade('a2', 'Visita técnica', '20/11/2026'),
        ]),
      },
    );

    await rolarAte(tester, find.text('Visita técnica'));
    expect(find.text('Atrasada'), findsOneWidget);
    expect(find.text('Agendada'), findsOneWidget);
  });

  group('colunasIndicadores', () {
    test('três indicadores ficam na mesma linha quando cabem', () {
      expect(
        colunasIndicadores(
          larguraDisponivel: 384,
          larguraMinimaCard: 110,
          quantidade: 3,
        ),
        3,
      );
    });

    test('quatro que não cabem viram duas linhas de dois', () {
      expect(
        colunasIndicadores(
          larguraDisponivel: 384,
          larguraMinimaCard: 110,
          quantidade: 4,
        ),
        2,
      );
    });

    test('três que não cabem lado a lado viram uma coluna', () {
      expect(
        colunasIndicadores(
          larguraDisponivel: 300,
          larguraMinimaCard: 120,
          quantidade: 3,
        ),
        1,
      );
    });

    test('texto muito largo usa uma coluna', () {
      expect(
        colunasIndicadores(
          larguraDisponivel: 300,
          larguraMinimaCard: 200,
          quantidade: 3,
        ),
        1,
      );
    });
  });

  for (final role in [UserRole.coordenador, UserRole.professor]) {
    for (final width in [320.0, 412.0, 900.0]) {
      testWidgets(
        'cards da mesma linha têm a mesma altura ${role.name} $width',
        (tester) async {
          await pumpDashboard(tester, role: role, size: Size(width, 915));
          final cards = find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('indicador-'),
          );
          final porLinha = <double, Set<double>>{};
          for (final element in cards.evaluate()) {
            final rect = tester.getRect(find.byWidget(element.widget));
            porLinha.putIfAbsent(rect.top, () => {}).add(rect.height);
          }
          expect(porLinha, isNotEmpty);
          for (final alturas in porLinha.values) {
            expect(alturas.length, 1, reason: 'alturas diferentes: $alturas');
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('frase do topo aparece inteira, sem corte', (tester) async {
    await pumpDashboard(tester, size: const Size(320, 568));
    final texto = find.descendant(
      of: find.byKey(const ValueKey('slide-frase')),
      matching: find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().length > 10,
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(texto);
    final completo = TextPainter(
      text: paragraph.text,
      textDirection: TextDirection.ltr,
      textScaler: paragraph.textScaler,
    )..layout(maxWidth: paragraph.size.width);
    expect(paragraph.size.height, closeTo(completo.height, 1));
    expect(paragraph.didExceedMaxLines, isFalse);
    completo.dispose();
  });

  group('colunasAtalhos', () {
    test('usa três colunas quando a maior palavra cabe', () {
      expect(colunasAtalhos(larguraDisponivel: 383, larguraMinimaCard: 110), 3);
    });

    test('reduz colunas para não partir palavras longas', () {
      expect(colunasAtalhos(larguraDisponivel: 383, larguraMinimaCard: 130), 2);
      expect(colunasAtalhos(larguraDisponivel: 292, larguraMinimaCard: 200), 1);
    });

    test('telas largas usam até cinco colunas', () {
      expect(colunasAtalhos(larguraDisponivel: 800, larguraMinimaCard: 110), 5);
    });
  });

  testWidgets('moldura do card do topo fica parada ao trocar de slide', (
    tester,
  ) async {
    await pumpDashboard(tester, avisos: [avisoReuniao, avisoProva]);
    final moldura = find.byKey(const Key('overview-carrossel'));
    final antes = tester.getRect(moldura);

    await tester.fling(moldura, const Offset(-300, 0), 1000);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getRect(moldura), antes, reason: 'durante a transição');
    await tester.pumpAndSettle();
    expect(tester.getRect(moldura), antes, reason: 'depois da transição');
    expect(find.byKey(const Key('dashboard-avisos')), findsOneWidget);
  });

  testWidgets('em tela alta o topo fica parado e só os cards rolam', (
    tester,
  ) async {
    await pumpDashboard(tester, size: const Size(412, 915));
    final topo = find.byKey(const Key('overview-header'));
    final antes = tester.getTopLeft(topo);

    await tester.drag(
      find.byKey(const Key('dashboard-rolagem')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(topo), antes);
    expect(
      find.descendant(
        of: find.byKey(const Key('dashboard-rolagem')),
        matching: topo,
      ),
      findsNothing,
    );
  });

  testWidgets('em tela baixa o topo rola junto para não tomar a tela', (
    tester,
  ) async {
    await pumpDashboard(tester, size: const Size(568, 320), textScale: 1.5);
    final topo = find.byKey(const Key('overview-header'));
    expect(
      find.descendant(
        of: find.byKey(const Key('dashboard-rolagem')),
        matching: topo,
      ),
      findsOneWidget,
    );
    final antes = tester.getTopLeft(topo);
    await tester.drag(
      find.byKey(const Key('dashboard-rolagem')),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(topo).dy, lessThan(antes.dy));
  });

  testWidgets('controles da tela têm ação de toque para o leitor de tela', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await pumpDashboard(tester, avisos: [avisoReuniao]);

    for (final rotulo in [
      'Perfil',
      RegExp('Ver todos os avisos'),
      RegExp('^Tarefas'),
    ]) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(rotulo).first),
        isSemantics(isButton: true, hasTapAction: true),
        reason: '$rotulo',
      );
    }

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantica.dispose();
  });
}
