import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/atividades/domain/atividades_service.dart';
import 'package:sigad/features/atividades/presentation/pages/atividades_page.dart';
import 'package:sigad/features/dashboard/domain/dashboard_summary.dart';

import 'helpers/work_items_fixtures.dart';

/// Segunda-feira, 16/11/2026, 09:30.
final _agora = DateTime(2026, 11, 16, 9, 30);

const _semana = Atividade(
  id: '#ATV-001',
  titulo: 'Reunião da semana',
  descricao: 'Pauta da semana',
  data: '18/11/2026 - 09:00',
  responsavel: 'Gestão',
  status: 'Pendente',
);
const _atrasada = Atividade(
  id: '#ATV-002',
  titulo: 'Entrega atrasada',
  descricao: 'Documento pendente',
  data: '10/11/2026',
  responsavel: 'TI',
  status: 'Agendada',
);
const _concluida = Atividade(
  id: '#ATV-003',
  titulo: 'Relatório concluído',
  descricao: 'Já entregue',
  data: '01/11/2026',
  responsavel: 'RH',
  status: 'Concluída',
);
const _semData = Atividade(
  id: '#ATV-004',
  titulo: 'Atividade sem data',
  descricao: 'Ainda sem data definida',
  data: '',
  responsavel: 'Coordenação',
  status: 'Pendente',
);
const _hoje = Atividade(
  id: '#ATV-005',
  titulo: 'Atividade de hoje',
  descricao: 'Acontece hoje',
  data: '16/11/2026 - 14:00',
  responsavel: 'Auditoria',
  status: 'Em progresso',
);
const _todas = [_semana, _atrasada, _concluida, _semData, _hoje];

Future<FakeAtividadeRepository> _abrir(
  WidgetTester tester, {
  List<Atividade> atividades = _todas,
  Size size = const Size(800, 1600),
  double textScale = 1,
}) async {
  configurarTela(tester, size);
  final repo = FakeAtividadeRepository(atividades);
  await tester.pumpWidget(
    appDeTeste(
      AtividadesPage(repository: repo, agora: _agora),
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder _campo(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
  description: 'TextField "$label"',
);

Future<void> _abrirFiltro(WidgetTester tester) async {
  final botao = find.byKey(const ValueKey('atividades_filter_button'));
  await tester.ensureVisible(botao);
  await tester.pumpAndSettle();
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

Future<void> _escolher(WidgetTester tester, String opcao) async {
  final chip = find.widgetWithText(ChoiceChip, opcao);
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('instalação nova mostra o estado vazio sem exemplos', (
    tester,
  ) async {
    configurarTela(tester, const Size(390, 844));
    await tester.pumpWidget(appDeTeste(const AtividadesPage()));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma atividade encontrada'), findsOneWidget);
    expect(find.text('Crie uma nova atividade para começar.'), findsOneWidget);
    expect(find.text('Limpar filtros'), findsNothing);
    expect(find.text('Treinamento de usuários'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('resumo mostra abertas, na semana e atrasadas', (tester) async {
    final semantics = tester.ensureSemantics();
    await _abrir(tester);
    expect(find.bySemanticsLabel('4 Abertas'), findsOneWidget);
    expect(find.bySemanticsLabel('2 Na semana'), findsOneWidget);
    expect(find.bySemanticsLabel('1 Atrasadas'), findsOneWidget);
    expect(find.text('Agenda operacional'), findsNothing);
    semantics.dispose();
  });

  testWidgets('card destaca atrasada e hoje com texto; sem data no fim', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.text('Atrasada · 10/11'), findsOneWidget);
    expect(find.text('Hoje · 14:00'), findsOneWidget);
    expect(find.text('Sem data'), findsOneWidget);
    // Concluída com data passada não é marcada como atrasada.
    expect(find.text('01/11/2026'), findsOneWidget);

    double topo(String titulo) => tester.getTopLeft(find.text(titulo)).dy;
    expect(topo('Relatório concluído'), lessThan(topo('Entrega atrasada')));
    expect(topo('Entrega atrasada'), lessThan(topo('Atividade de hoje')));
    expect(topo('Atividade de hoje'), lessThan(topo('Reunião da semana')));
    expect(topo('Reunião da semana'), lessThan(topo('Atividade sem data')));
  });

  group('filtro', () {
    testWidgets('aplica só ao tocar em Aplicar e mostra o selo', (
      tester,
    ) async {
      await _abrir(tester);
      await _abrirFiltro(tester);
      expect(find.widgetWithText(ChoiceChip, 'Todas'), findsOneWidget);
      await _escolher(tester, 'Concluída');
      expect(find.text('Entrega atrasada'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar'));
      await tester.pumpAndSettle();
      expect(find.text('Relatório concluído'), findsOneWidget);
      expect(find.text('Entrega atrasada'), findsNothing);
      expect(find.byTooltip('Filtros ativos: 1'), findsOneWidget);
      final badge = tester.widget<Badge>(
        find.descendant(
          of: find.byKey(const ValueKey('atividades_filter_button')),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('fechar sem aplicar descarta a seleção', (tester) async {
      await _abrir(tester);
      await _abrirFiltro(tester);
      await _escolher(tester, 'Concluída');
      await tester.tap(find.byTooltip('Fechar filtro'));
      await tester.pumpAndSettle();
      expect(find.text('Entrega atrasada'), findsOneWidget);
      expect(find.byTooltip('Filtrar atividades'), findsOneWidget);
    });

    testWidgets('vazio com filtro e busca oferece Limpar filtros', (
      tester,
    ) async {
      await _abrir(tester);
      await _abrirFiltro(tester);
      await _escolher(tester, 'Concluída');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('atividades_search_field')),
        'reunião',
      );
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma atividade encontrada'), findsOneWidget);

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Reunião da semana'), findsOneWidget);
      expect(find.text('Relatório concluído'), findsOneWidget);
      final busca = tester.widget<TextField>(
        find.byKey(const ValueKey('atividades_search_field')),
      );
      expect(busca.controller!.text, isEmpty);
      expect(busca.decoration!.labelText, 'Buscar atividades');
    });
  });

  group('formulário', () {
    testWidgets('validação aparece no campo', (tester) async {
      final repo = await _abrir(tester);
      await tester.tap(find.byTooltip('Criar nova atividade'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_campo('Título')).decoration!.errorText,
        'Informe o título da atividade',
      );
      expect(
        tester.widget<TextField>(_campo('Descrição')).decoration!.errorText,
        'Informe a descrição da atividade',
      );
      expect(repo.saves, 0);
    });

    testWidgets('criar sem data grava vazio e mostra "Sem data"', (
      tester,
    ) async {
      final repo = await _abrir(tester, atividades: const []);
      await tester.tap(find.byTooltip('Criar nova atividade'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Título'), 'Nova sem data');
      await tester.enterText(_campo('Descrição'), 'Descrição');
      // Sem data, a hora fica indisponível.
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('atividade_hora_field')),
            )
            .enabled,
        isFalse,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      expect(repo.atividades.single.data, isEmpty);
      expect(find.text('Sem data'), findsOneWidget);
      expect(find.text('Atividade criada com sucesso!'), findsOneWidget);
    });

    testWidgets('criar com data e hora grava "dd/MM/aaaa - HH:mm"', (
      tester,
    ) async {
      final repo = await _abrir(tester, atividades: const []);
      await tester.tap(find.byTooltip('Criar nova atividade'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Título'), 'Com data');
      await tester.enterText(_campo('Descrição'), 'Descrição');

      await tester.tap(find.byKey(const ValueKey('atividade_data_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final hora = find.byKey(const ValueKey('atividade_hora_field'));
      await tester.ensureVisible(hora);
      await tester.tap(hora);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      final data = repo.atividades.single.data;
      expect(data, '20/11/2026 - 09:30');
      expect(DashboardSummary.dataDaAtividade(data), DateTime(2026, 11, 20));
    });

    testWidgets('editar sem mexer na data preserva o texto gravado', (
      tester,
    ) async {
      final repo = await _abrir(tester, atividades: const [_semana]);
      await tester.tap(find.byTooltip('Mais ações da atividade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar').last);
      await tester.pumpAndSettle();
      expect(find.text('18/11/2026'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repo.atividades.single.data, '18/11/2026 - 09:00');
    });

    testWidgets('falha ao gravar mantém o formulário sem anunciar sucesso', (
      tester,
    ) async {
      final repo = await _abrir(tester);
      repo.falha = StateError('falha');
      await tester.tap(find.byTooltip('Criar nova atividade'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Título'), 'Não grava');
      await tester.enterText(_campo('Descrição'), 'Descrição');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      expect(find.text('Nova Atividade'), findsOneWidget);
      expect(find.text('Atividade criada com sucesso!'), findsNothing);
      expect(
        find.text(
          'Não foi possível salvar a atividade. Seus dados foram mantidos. '
          'Tente novamente.',
        ),
        findsOneWidget,
      );
      expect(repo.atividades, hasLength(_todas.length));
    });
  });

  test('formata e lê data e hora no padrão gravado', () {
    expect(AtividadesService.formatarData(null), isEmpty);
    expect(AtividadesService.formatarData(DateTime(2026, 3, 7)), '07/03/2026');
    expect(
      AtividadesService.formatarData(DateTime(2026, 3, 7), hora: 8, minuto: 5),
      '07/03/2026 - 08:05',
    );
    final hora = AtividadesService.horaDaAtividade('07/03/2026 - 08:05');
    expect(hora?.hora, 8);
    expect(hora?.minuto, 5);
    expect(AtividadesService.horaDaAtividade('07/03/2026'), isNull);
  });

  group('matriz visual sem overflow', () {
    for (final size in matrizTamanhos) {
      for (final escala in matrizEscalas) {
        testWidgets('lista ${size.width.toInt()}x${size.height.toInt()} '
            'fonte ${(escala * 100).toInt()}%', (tester) async {
          await _abrir(tester, size: size, textScale: escala);
          semExcecao(tester, 'lista');
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -2000),
          );
          await tester.pumpAndSettle();
          semExcecao(tester, 'lista rolada');
        });
      }
    }

    for (final size in const [Size(320, 568), Size(568, 320)]) {
      testWidgets('sheets ${size.width.toInt()}x${size.height.toInt()} '
          'fonte 200%', (tester) async {
        await _abrir(tester, size: size, textScale: 2);

        await _abrirFiltro(tester);
        semExcecao(tester, 'filtro');
        final aplicar = find.widgetWithText(ElevatedButton, 'Aplicar');
        await tester.ensureVisible(aplicar);
        await tester.pumpAndSettle();
        expect(aplicar.hitTestable(), findsOneWidget);
        await tester.tap(aplicar);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Entrega atrasada'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Entrega atrasada'));
        await tester.pumpAndSettle();
        semExcecao(tester, 'detalhe');
        await tester.tap(find.byTooltip('Fechar detalhes da atividade'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Criar nova atividade'));
        await tester.pumpAndSettle();
        semExcecao(tester, 'formulário');
        final criar = find.widgetWithText(ElevatedButton, 'Criar');
        await tester.ensureVisible(criar);
        await tester.pumpAndSettle();
        expect(criar.hitTestable(), findsOneWidget);
      });
    }
  });
}
