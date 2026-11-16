import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/app/theme/sigad_icons.dart';
import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/relatorios/domain/relatorio_models.dart';
import 'package:sigad/features/relatorios/presentation/pages/relatorios_page.dart';
import 'package:sigad/l10n/l10n.dart';

import 'helpers/relatorios_fixtures.dart';

Future<FakeRelatorioRepository> _abrir(
  WidgetTester tester, {
  FakeRelatorioRepository? repository,
  Size tamanho = const Size(390, 844),
  double escala = 1,
  bool escuro = false,
  UserRole perfil = UserRole.coordenador,
}) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repo = repository ?? FakeRelatorioRepository();
  final userContext = UserContextProvider();
  await userContext.login(
    User(
      id: 'relatorios-page',
      name: 'Usuária Teste',
      email: 'teste@exemplo.edu.br',
      role: perfil,
      createdAt: DateTime(2026),
    ),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<UserContextProvider>.value(
      value: userContext,
      child: MaterialApp(
        theme: escuro ? AppTheme.dark() : AppTheme.light(),
        locale: const Locale('pt'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(escala)),
          child: child!,
        ),
        home: Scaffold(body: RelatoriosPage(repository: repo)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

/// Textos dos antigos exemplos fictícios que não podem voltar à produção.
const _textosFicticios = [
  'Departamento de RH',
  'Auditoria Interna',
  'Conformidade com Normas ISO',
  'Mapeamento de Demandas do Período',
  'Central de relatórios',
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('sem dados mostra o estado vazio e nenhum relatório fictício', (
    tester,
  ) async {
    await _abrir(tester);

    expect(find.text('Nenhum relatório disponível'), findsOneWidget);
    expect(
      find.text(
        'Quando houver relatórios publicados para o seu perfil, eles '
        'aparecerão aqui.',
      ),
      findsOneWidget,
    );
    for (final texto in _textosFicticios) {
      expect(find.textContaining(texto), findsNothing, reason: texto);
    }
    expect(find.textContaining('demonstrativ'), findsNothing);
    // Sem dados, não há indicadores numéricos nem busca.
    expect(find.text('Total'), findsNothing);
    expect(find.text('Publicados'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro mostra estado de erro e tenta novamente', (tester) async {
    final repo = await _abrir(
      tester,
      repository: FakeRelatorioRepository(erro: Exception('falha')),
    );

    expect(find.text('Não foi possível carregar os relatórios.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('Total'), findsNothing);
    for (final texto in _textosFicticios) {
      expect(find.textContaining(texto), findsNothing, reason: texto);
    }

    repo
      ..erro = null
      ..dados = relatoriosFixture.take(2).toList();
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(repo.chamadas, 2);
    expect(find.text('Distribuição de Carga Horária Docente'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('com dados mostra indicadores e sem cabeçalho repetido', (
    tester,
  ) async {
    await _abrir(
      tester,
      repository: FakeRelatorioRepository(dados: relatoriosFixture),
    );

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Disponíveis'), findsNothing);
    expect(find.text('Central de relatórios'), findsNothing);
    expect(find.textContaining('disponíveis para consulta'), findsNothing);
    expect(find.textContaining('Arraste'), findsNothing);
    expect(find.textContaining('resultado'), findsNothing);
    expect(find.textContaining('PDF baixado'), findsNothing);
    // Filtros de status quebram linha em vez de rolar na horizontal.
    final horizontais = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where((s) => axisDirectionToAxis(s.axisDirection) == Axis.horizontal)
        .where(
          (s) => find
              .ancestor(of: find.byWidget(s), matching: find.byType(TextField))
              .evaluate()
              .isEmpty,
        );
    expect(horizontais, isEmpty);
  });

  testWidgets('busca mostra a contagem de resultados e vazio filtrado', (
    tester,
  ) async {
    await _abrir(
      tester,
      repository: FakeRelatorioRepository(dados: relatoriosFixture),
    );

    await tester.enterText(find.byType(TextField), 'laboratórios');
    await tester.pumpAndSettle();
    expect(find.text('1 resultado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Nenhum resultado'), findsOneWidget);
    expect(find.text('Nenhum relatório encontrado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.widgetWithText(FilterChip, 'Agendado'));
    await tester.pumpAndSettle();
    expect(find.text('1 resultado'), findsOneWidget);
  });

  testWidgets('menu usa ícones de copiar resumo e de e-mail', (tester) async {
    await _abrir(
      tester,
      repository: FakeRelatorioRepository(dados: [relatoriosFixture.first]),
    );

    await tester.tap(find.byTooltip('Mais ações do relatório'));
    await tester.pumpAndSettle();

    final copiar = find.ancestor(
      of: find.text('Copiar resumo'),
      matching: find.byType(PopupMenuItem<String>),
    );
    final email = find.ancestor(
      of: find.text('Enviar por e-mail'),
      matching: find.byType(PopupMenuItem<String>),
    );
    expect(
      find.descendant(of: copiar, matching: find.byIcon(SigadIcons.documentoResumo)),
      findsWidgets,
    );
    expect(
      find.descendant(of: email, matching: find.byIcon(SigadIcons.email)),
      findsWidgets,
    );
    expect(find.byIcon(SigadIcons.baixar), findsNothing);
    expect(find.byIcon(SigadIcons.compartilhar), findsNothing);
  });

  testWidgets('status tem ícone e texto, com rótulo acessível', (tester) async {
    await _abrir(
      tester,
      repository: FakeRelatorioRepository(dados: [relatoriosFixture[3]]),
    );
    expect(find.bySemanticsLabel('Situação: Em revisão'), findsOneWidget);
    expect(find.byIcon(SigadIcons.pendente), findsWidgets);
  });

  group('detalhes', () {
    const longo = Relatorio(
      id: '#REL-900',
      titulo:
          'Relatório consolidado de acompanhamento das atividades acadêmicas '
          'e administrativas do departamento no semestre letivo',
      descricao: 'Descrição longa para verificar a quebra de linha no sheet.',
      tipo: 'Análise Geral',
      data: '01/10/2026',
      autor: 'Coordenação',
      status: 'Publicado',
    );

    Future<(Offset, Offset)> abrirDetalhes(
      WidgetTester tester, {
      required Size tamanho,
      double escala = 1,
    }) async {
      await _abrir(
        tester,
        repository: FakeRelatorioRepository(dados: [longo]),
        tamanho: tamanho,
        escala: escala,
      );
      final card = find.textContaining('Relatório consolidado');
      await tester.scrollUntilVisible(
        card,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Título completo, sem truncamento.
      final titulo = tester.widget<Text>(find.text(longo.titulo).last);
      expect(titulo.maxLines, isNull);
      final copiar = find.widgetWithText(OutlinedButton, 'Copiar resumo');
      final email = find.widgetWithText(ElevatedButton, 'Enviar por e-mail');
      expect(copiar, findsOneWidget);
      expect(email, findsOneWidget);
      return (tester.getCenter(copiar), tester.getCenter(email));
    }

    testWidgets('empilha botões abaixo de 400 de largura', (tester) async {
      final (copiar, email) = await abrirDetalhes(
        tester,
        tamanho: const Size(390, 844),
      );
      expect(email.dy, greaterThan(copiar.dy));
    });

    testWidgets('botões lado a lado com largura ≥ 400 e fonte normal', (
      tester,
    ) async {
      final (copiar, email) = await abrirDetalhes(
        tester,
        tamanho: const Size(412, 915),
      );
      expect(email.dy, copiar.dy);
    });

    testWidgets('empilha botões com fonte ampliada', (tester) async {
      final (copiar, email) = await abrirDetalhes(
        tester,
        tamanho: const Size(412, 915),
        escala: 1.5,
      );
      expect(email.dy, greaterThan(copiar.dy));
    });

    for (final tamanho in const [Size(320, 568), Size(568, 320)]) {
      testWidgets('sem overflow em $tamanho a 200%', (tester) async {
        await abrirDetalhes(tester, tamanho: tamanho, escala: 2);
        await tester.scrollUntilVisible(
          find.text('Enviar por e-mail'),
          100,
          scrollable: find
              .descendant(
                of: find.byType(BottomSheet),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
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
          await _abrir(
            tester,
            repository: FakeRelatorioRepository(dados: relatoriosFixture),
            tamanho: tamanho,
            escala: escala,
          );
          expect(tester.takeException(), isNull);
          final lista = find.byType(Scrollable).first;
          await tester.scrollUntilVisible(
            find.text('Auditoria Interna'),
            200,
            scrollable: lista,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    for (final escuro in [false, true]) {
      testWidgets('390x844 tema ${escuro ? 'escuro' : 'claro'}', (
        tester,
      ) async {
        await _abrir(
          tester,
          repository: FakeRelatorioRepository(dados: relatoriosFixture),
          escuro: escuro,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Total'), findsOneWidget);
      });
    }

    for (final tamanho in const [Size(320, 568), Size(568, 320)]) {
      testWidgets('estados vazio e erro em $tamanho a 200%', (tester) async {
        await _abrir(tester, tamanho: tamanho, escala: 2);
        expect(tester.takeException(), isNull);
        await _abrir(
          tester,
          repository: FakeRelatorioRepository(erro: Exception('x')),
          tamanho: tamanho,
          escala: 2,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
