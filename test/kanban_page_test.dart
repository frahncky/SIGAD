import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/features/kanban/domain/kanban_models.dart';
import 'package:sigad/features/kanban/presentation/pages/kanban_page.dart';

import 'helpers/work_items_fixtures.dart';

Future<FakeKanbanRepository> _abrir(
  WidgetTester tester, {
  List<KanbanCardModel> cards = kanbanFixture,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  configurarTela(tester, size);
  final repo = FakeKanbanRepository(cards);
  await tester.pumpWidget(
    appDeTeste(KanbanPage(repository: repo), textScale: textScale),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _abrirMenu(WidgetTester tester, {int indice = 0}) async {
  final menu = find.byTooltip('Mais ações da tarefa').at(indice);
  await tester.ensureVisible(menu);
  await tester.pumpAndSettle();
  await tester.tap(menu);
  await tester.pumpAndSettle();
}

KanbanCardModel _card(FakeKanbanRepository repo, int id) =>
    repo.cards.firstWhere((c) => c.id == id);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('instalação nova mostra o estado vazio sem tarefas de exemplo', (
    tester,
  ) async {
    configurarTela(tester, const Size(390, 844));
    await tester.pumpWidget(appDeTeste(const KanbanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma tarefa criada'), findsOneWidget);
    expect(
      find.text('Toque no + para adicionar a primeira tarefa ao quadro.'),
      findsOneWidget,
    );
    expect(find.text('Revisão de inventário'), findsNothing);
    // Sem AppBar interno e sem botão duplicado de criar no estado vazio.
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(
      find.widgetWithIcon(FloatingActionButton, Icons.add),
      findsNothing,
      reason: 'O FAB usa o ícone próprio do SIGAD.',
    );
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    expect(find.byTooltip('Nova tarefa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('celular mostra uma coluna por vez com seletor de colunas', (
    tester,
  ) async {
    await _abrir(tester);
    expect(
      find.byKey(const ValueKey('kanban_column_selector')),
      findsOneWidget,
    );
    expect(find.text('Backlog · 2'), findsOneWidget);
    expect(find.text('Em Progresso · 2'), findsOneWidget);
    expect(find.text('Revisão de inventário'), findsOneWidget);
    expect(find.text('Mapear demandas'), findsNothing);

    await tester.tap(find.text('Em Progresso · 2'));
    await tester.pumpAndSettle();
    expect(find.text('Mapear demandas'), findsOneWidget);
    expect(find.text('Revisão de inventário'), findsNothing);
    expect(
      tester.getSize(find.widgetWithText(ChoiceChip, 'Backlog · 2')).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('coluna vazia mostra "Nenhuma tarefa" e não "Solte aqui"', (
    tester,
  ) async {
    await _abrir(tester, cards: [kanbanFixture.first]);
    await tester.ensureVisible(find.text('Em Revisão · 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Em Revisão · 0'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma tarefa'), findsOneWidget);
    expect(find.text('Solte aqui'), findsNothing);
  });

  testWidgets('tela larga mostra colunas lado a lado com largura limitada', (
    tester,
  ) async {
    await _abrir(tester, size: const Size(1280, 800));
    expect(find.byKey(const ValueKey('kanban_column_selector')), findsNothing);
    for (final coluna in ['Backlog', 'Em Progresso', 'Em Revisão']) {
      expect(find.text(coluna), findsOneWidget);
    }
    final backlog = tester.getTopLeft(find.text('Backlog')).dx;
    final progresso = tester.getTopLeft(find.text('Em Progresso')).dx;
    final larguraColuna = progresso - backlog - 12;
    expect(larguraColuna, inInclusiveRange(260, 320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Mover para…" lista as outras colunas com contagem e move', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await _abrirMenu(tester);
    await tester.tap(find.text('Mover para…'));
    await tester.pumpAndSettle();

    final opcoes = find.byType(ListTile);
    expect(opcoes, findsNWidgets(3));
    expect(find.widgetWithText(ListTile, 'Backlog'), findsNothing);
    expect(find.widgetWithText(ListTile, '2 tarefas'), findsNWidgets(2));
    expect(find.widgetWithText(ListTile, '1 tarefa'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Em Progresso'));
    await tester.pumpAndSettle();

    expect(repo.saves, 1);
    expect(_card(repo, 1).coluna, 'Em Progresso');
    expect(find.text('Backlog · 1'), findsOneWidget);
    expect(find.text('Em Progresso · 3'), findsOneWidget);
    expect(find.text('Tarefa movida para Em Progresso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('falha ao gravar desfaz a movimentação e mostra erro', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    repo.falha = StateError('falha');
    await _abrirMenu(tester);
    await tester.tap(find.text('Mover para…'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Concluído'));
    await tester.pumpAndSettle();

    expect(find.text('Backlog · 2'), findsOneWidget);
    expect(find.text('Concluído · 1'), findsOneWidget);
    expect(
      find.text('Não foi possível salvar o quadro. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.textContaining('Tarefa movida'), findsNothing);
  });

  testWidgets('tarefa oferece ações de acessibilidade "Mover para"', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    final semantics = tester.widget<Semantics>(
      find.byKey(const ValueKey('kanban_card_semantics_1')),
    );
    final acoes = semantics.properties.customSemanticsActions!;
    expect(acoes.keys.map((a) => a.label), [
      'Mover para Em Progresso',
      'Mover para Em Revisão',
      'Mover para Concluído',
    ]);
    acoes.entries.last.value();
    await tester.pumpAndSettle();
    expect(_card(repo, 1).coluna, 'Concluído');
  });

  testWidgets('toque longo arrasta a tarefa para outra coluna', (tester) async {
    final repo = await _abrir(tester);
    final origem = tester.getCenter(find.text('Revisão de inventário'));
    final gesture = await tester.startGesture(origem);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text('Em Progresso · 2')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_card(repo, 1).coluna, 'Em Progresso');
    expect(find.text('Em Progresso · 3'), findsOneWidget);
  });

  testWidgets('arraste curto não move a tarefa (rolagem livre)', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await tester.drag(
      find.text('Revisão de inventário'),
      const Offset(0, -80),
      kind: PointerDeviceKind.touch,
    );
    await tester.pumpAndSettle();
    expect(repo.saves, 0);
  });

  testWidgets('excluir pede uma única confirmação citando o título', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await _abrirMenu(tester);
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(
      find.text('Deseja excluir a tarefa "Revisão de inventário"?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(repo.cards, hasLength(kanbanFixture.length - 1));
    expect(
      find.text('Tarefa "Revisão de inventário" removida'),
      findsOneWidget,
    );
  });

  testWidgets('criar valida no campo e só anuncia sucesso após gravar', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await tester.tap(find.byTooltip('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o título da tarefa'), findsOneWidget);
    expect(repo.saves, 0);

    await tester.enterText(find.byType(TextField), 'Nova tarefa de teste');
    repo.pendente = Completer<void>();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
    await tester.pump();
    expect(find.text('Salvando...'), findsOneWidget);
    expect(find.text('Tarefa criada com sucesso!'), findsNothing);

    repo.pendente!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Tarefa criada com sucesso!'), findsOneWidget);
    expect(repo.cards.last.titulo, 'Nova tarefa de teste');
  });

  testWidgets('detalhe não mostra o identificador interno', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Revisão de inventário'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('ID:'), findsNothing);
  });

  group('matriz visual sem overflow', () {
    for (final size in matrizTamanhos) {
      for (final escala in matrizEscalas) {
        testWidgets('quadro ${size.width.toInt()}x${size.height.toInt()} '
            'fonte ${(escala * 100).toInt()}%', (tester) async {
          await _abrir(tester, size: size, textScale: escala);
          semExcecao(tester, 'quadro');
        });
      }
    }

    for (final size in const [Size(320, 568), Size(568, 320)]) {
      testWidgets('ações ${size.width.toInt()}x${size.height.toInt()} '
          'fonte 200%', (tester) async {
        await _abrir(tester, size: size, textScale: 2);
        await _abrirMenu(tester);
        semExcecao(tester, 'menu');
        await tester.tap(find.text('Mover para…'));
        await tester.pumpAndSettle();
        semExcecao(tester, 'mover para');
        await tester.tap(find.byTooltip('Fechar'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Nova tarefa'));
        await tester.pumpAndSettle();
        semExcecao(tester, 'nova tarefa');
        final criar = find.widgetWithText(ElevatedButton, 'Criar');
        await tester.ensureVisible(criar);
        await tester.pumpAndSettle();
        expect(criar.hitTestable(), findsOneWidget);
      });
    }

    testWidgets('colunas lado a lado 1024x768 fonte 200%', (tester) async {
      await _abrir(tester, size: const Size(1024, 768), textScale: 2);
      expect(find.text('Backlog'), findsOneWidget);
      semExcecao(tester, 'quadro largo');
    });

    testWidgets('estado vazio 568x320 fonte 200%', (tester) async {
      await _abrir(
        tester,
        cards: const [],
        size: const Size(568, 320),
        textScale: 2,
      );
      expect(find.text('Nenhuma tarefa criada'), findsOneWidget);
      semExcecao(tester, 'vazio');
    });
  });
}
