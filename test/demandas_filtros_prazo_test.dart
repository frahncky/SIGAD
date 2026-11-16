import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sigad/core/models/user.dart';
import 'package:sigad/core/models/user_role.dart';
import 'package:sigad/core/services/user_context_provider.dart';
import 'package:sigad/features/demandas/data/demanda_repository.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/demandas/domain/demandas_service.dart';
import 'package:sigad/features/demandas/presentation/pages/demandas_page.dart';

import 'helpers/work_items_fixtures.dart';

class _MemRepository extends DemandaRepository {
  _MemRepository(List<Demanda> demandas)
    : demandas = List.of(demandas),
      super(storageKey: 'mem_demandas');

  List<Demanda> demandas;
  int saves = 0;

  @override
  Future<List<Demanda>> loadDemandas() async => List.of(demandas);

  @override
  Future<void> saveDemandas(List<Demanda> novas) async {
    saves++;
    demandas = List.of(novas);
  }
}

/// 20/04/2026: DEM-002 vence hoje, DEM-001 está atrasada.
final _agora = DateTime(2026, 4, 20, 9);

Future<UserContextProvider> _coordenacao() async {
  final userContext = UserContextProvider();
  addTearDown(userContext.dispose);
  await userContext.login(
    User(
      id: 'coordenador-demandas',
      name: 'Coordenação Teste',
      email: 'coordenacao@exemplo.edu.br',
      role: UserRole.coordenador,
      createdAt: DateTime(2026),
    ),
  );
  return userContext;
}

Future<_MemRepository> _abrir(
  WidgetTester tester, {
  List<Demanda>? demandas,
  Size size = const Size(800, 1600),
  double textScale = 1,
}) async {
  configurarTela(tester, size);
  final repo = _MemRepository(demandas ?? DemandasService.defaultDemandas());
  final userContext = await _coordenacao();
  await tester.pumpWidget(
    ChangeNotifierProvider<UserContextProvider>.value(
      value: userContext,
      child: appDeTeste(
        DemandasPage(repository: repo, agora: _agora),
        textScale: textScale,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Finder _campo(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
  description: 'TextField "$label"',
);

Future<void> _abrirFiltros(WidgetTester tester) async {
  final botao = find.byKey(const ValueKey('demandas_filter_button'));
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

const _concluida = 'Relatório de uso dos laboratórios';
const _nova = 'Mapear demandas semestre 2026.1';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('filtros de demandas', () {
    testWidgets('lista só muda depois de Aplicar', (tester) async {
      await _abrir(tester);
      expect(find.text(_nova), findsOneWidget);

      await _abrirFiltros(tester);
      await _escolher(tester, 'Concluído');
      // A seleção ainda não foi aplicada: a página atrás do sheet não muda.
      expect(find.text(_nova), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar'));
      await tester.pumpAndSettle();
      expect(find.text(_concluida), findsOneWidget);
      expect(find.text(_nova), findsNothing);
      expect(find.byTooltip('Filtros ativos: 1'), findsOneWidget);
      semExcecao(tester, 'aplicar filtro');
    });

    testWidgets('fechar pelo X ou tocando fora descarta a seleção', (
      tester,
    ) async {
      await _abrir(tester);
      await _abrirFiltros(tester);
      await _escolher(tester, 'Concluído');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar'));
      await tester.pumpAndSettle();

      await _abrirFiltros(tester);
      await _escolher(tester, 'Novo');
      await tester.tap(find.byTooltip('Fechar filtros'));
      await tester.pumpAndSettle();
      expect(find.text(_concluida), findsOneWidget);
      expect(find.text(_nova), findsNothing);

      await _abrirFiltros(tester);
      // Ao reabrir, o sheet mostra o filtro aplicado, não o descartado.
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Concluído'))
            .selected,
        isTrue,
      );
      await _escolher(tester, 'Novo');
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text(_concluida), findsOneWidget);
      expect(find.text(_nova), findsNothing);
    });

    testWidgets('Limpar zera os filtros e aplica', (tester) async {
      await _abrir(tester);
      await _abrirFiltros(tester);
      await _escolher(tester, 'Concluído');
      await _escolher(tester, 'Baixa');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aplicar'));
      await tester.pumpAndSettle();
      expect(find.text(_nova), findsNothing);

      await _abrirFiltros(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Limpar'));
      await tester.pumpAndSettle();
      expect(find.text(_nova), findsOneWidget);
      expect(find.text(_concluida), findsOneWidget);
      expect(find.byTooltip('Filtrar demandas'), findsOneWidget);
    });

    testWidgets('vazio com busca oferece Limpar filtros e limpa o campo', (
      tester,
    ) async {
      await _abrir(tester);
      await tester.enterText(
        find.byKey(const ValueKey('demandas_search_field')),
        'inexistente',
      );
      await tester.pumpAndSettle();
      expect(find.text('Nenhuma demanda encontrada'), findsOneWidget);
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      expect(find.text(_nova), findsOneWidget);
      final busca = tester.widget<TextField>(
        find.byKey(const ValueKey('demandas_search_field')),
      );
      expect(busca.controller!.text, isEmpty);
    });
  });

  group('prazo e indicadores', () {
    testWidgets('situação do prazo usa ícone e texto, sem atraso em '
        'concluída', (tester) async {
      await _abrir(tester);
      expect(find.text('Vence hoje'), findsOneWidget);
      expect(find.text('Atrasada · 15/04/2026'), findsOneWidget);
      // DEM-005 está concluída: o prazo passado não vira "Atrasada".
      expect(find.text('10/04/2026'), findsOneWidget);
      expect(find.text('Atrasada · 10/04/2026'), findsNothing);
    });

    testWidgets('Prioridade alta conta só demandas abertas', (tester) async {
      final semantics = tester.ensureSemantics();
      await _abrir(
        tester,
        demandas: [
          ...DemandasService.defaultDemandas(),
          const Demanda(
            id: '#DEM-006',
            titulo: 'Alta já concluída',
            descricao: 'x',
            prioridade: 'Alta',
            statusLabel: 'Concluído',
            proprietario: 'Chefia do DEE',
            prazo: '',
          ),
        ],
      );
      expect(find.bySemanticsLabel('2 Prioridade alta'), findsOneWidget);
      expect(find.bySemanticsLabel('6 No total'), findsOneWidget);
      expect(find.bySemanticsLabel('4 Abertas'), findsOneWidget);
      expect(find.text('Urgentes'), findsNothing);
      semantics.dispose();
    });

    testWidgets('criar sem prazo grava vazio, mostra "Sem prazo" e ordena '
        'no fim', (tester) async {
      final repo = await _abrir(tester);
      await tester.tap(find.byTooltip('Criar nova demanda'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Título'), 'Demanda sem prazo');
      await tester.enterText(_campo('Descrição'), 'Descrição');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();

      expect(repo.saves, 1);
      expect(repo.demandas.first.prazo, isEmpty);
      expect(find.text('Sem prazo'), findsOneWidget);
      final ultima = tester.getTopLeft(find.text('Demanda sem prazo')).dy;
      final anterior = tester
          .getTopLeft(find.text('Padronizar formulários de requisição'))
          .dy;
      expect(ultima, greaterThan(anterior));
    });

    testWidgets('criar com prazo usa o seletor de data e grava dd/MM/aaaa', (
      tester,
    ) async {
      final repo = await _abrir(tester);
      await tester.tap(find.byTooltip('Criar nova demanda'));
      await tester.pumpAndSettle();
      await tester.enterText(_campo('Título'), 'Demanda com prazo');
      await tester.enterText(_campo('Descrição'), 'Descrição');

      await tester.tap(find.byKey(const ValueKey('demanda_prazo_field')));
      await tester.pumpAndSettle();
      expect(find.text('Selecionar prazo'), findsOneWidget);
      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('demanda_prazo_field')),
          matching: find.text('25/04/2026'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      expect(repo.demandas.first.prazo, '25/04/2026');
    });

    testWidgets('edição preserva o prazo e permite removê-lo', (tester) async {
      final repo = await _abrir(
        tester,
        demandas: [DemandasService.defaultDemandas().first],
      );
      Future<void> editar() async {
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar').last);
        await tester.pumpAndSettle();
      }

      await editar();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repo.demandas.single.prazo, '15/04/2026');

      await editar();
      await tester.tap(find.byTooltip('Remover prazo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(repo.demandas.single.prazo, isEmpty);
      expect(find.text('Sem prazo'), findsOneWidget);
    });

    testWidgets('validação aparece no campo', (tester) async {
      final repo = await _abrir(tester);
      await tester.tap(find.byTooltip('Criar nova demanda'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar'));
      await tester.pumpAndSettle();
      final titulo = tester.widget<TextField>(_campo('Título'));
      expect(titulo.decoration!.errorText, 'Informe o título da demanda');
      expect(repo.saves, 0);
    });
  });

  test('ordenação por prazo põe sem prazo no fim', () {
    const base = Demanda(
      id: '#DEM-001',
      titulo: 't',
      descricao: 'd',
      prioridade: 'Alta',
      statusLabel: 'Novo',
      proprietario: 'p',
      prazo: '',
    );
    final ordenadas = DemandasService.ordenarDemandas([
      base,
      base.copyWith(prazo: '30/04/2026'),
      base.copyWith(prazo: '10/04/2026'),
    ], 'Prazo mais próximo');
    expect(ordenadas.map((d) => d.prazo), ['10/04/2026', '30/04/2026', '']);
    expect(DemandasService.formatarPrazo(DateTime(2026, 3, 7)), '07/03/2026');
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

        await _abrirFiltros(tester);
        semExcecao(tester, 'filtros');
        final aplicar = find.widgetWithText(ElevatedButton, 'Aplicar');
        await tester.ensureVisible(aplicar);
        await tester.pumpAndSettle();
        expect(aplicar.hitTestable(), findsOneWidget);
        await tester.tap(aplicar);
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Vence hoje'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vence hoje'));
        await tester.pumpAndSettle();
        semExcecao(tester, 'detalhe');
        expect(find.text(_nova), findsWidgets);
        await tester.tap(find.byTooltip('Fechar detalhes da demanda'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Criar nova demanda'));
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
