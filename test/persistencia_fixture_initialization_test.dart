import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/core/services/local_storage_service.dart';
import 'package:sigad/features/atividades/data/atividade_repository.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/demandas/data/demanda_repository.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/kanban/data/kanban_repository.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';
import 'package:sigad/features/relatorios/data/relatorio_repository.dart';
import 'package:sigad/features/relatorios/domain/relatorio_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('armazenamento distingue chave ausente de lista vazia', () async {
    expect(await LocalStorageService.loadListOrNull('lista'), isNull);

    await LocalStorageService.saveList('lista', const []);

    expect(await LocalStorageService.loadListOrNull('lista'), isEmpty);
  });

  test('demandas de demonstração são inseridas somente uma vez', () async {
    const seed = Demanda(
      id: '#DEM-001',
      titulo: 'Demanda inicial',
      descricao: 'Exemplo',
      prioridade: 'Alta',
      statusLabel: 'Novo',
      proprietario: 'Coordenação',
      prazo: '01/01/2026',
    );
    final repository = DemandaRepository(
      storageKey: 'fixture_demandas',
      dataSourceMode: DataSourceMode.local,
    );

    final primeiraCarga = await repository.loadDemandas(
      initialData: const [seed],
    );
    await repository.saveDemandas(const []);
    final aposExcluirTudo = await repository.loadDemandas(
      initialData: const [seed],
    );

    expect(primeiraCarga.single.id, seed.id);
    expect(aposExcluirTudo, isEmpty);
  });

  test('atividades de demonstração são inseridas somente uma vez', () async {
    const seed = Atividade(
      id: '#ATV-001',
      titulo: 'Atividade inicial',
      descricao: 'Exemplo',
      data: '01/01/2026',
      responsavel: 'Coordenação',
      status: 'Pendente',
    );
    final repository = AtividadeRepository(
      storageKey: 'fixture_atividades',
      dataSourceMode: DataSourceMode.local,
    );

    final primeiraCarga = await repository.loadAtividades(
      initialData: const [seed],
    );
    await repository.saveAtividades(const []);
    final aposExcluirTudo = await repository.loadAtividades(
      initialData: const [seed],
    );

    expect(primeiraCarga.single.id, seed.id);
    expect(aposExcluirTudo, isEmpty);
  });

  test('cards de demonstração são inseridos somente uma vez', () async {
    const seed = KanbanCardModel(
      id: 1,
      titulo: 'Card inicial',
      coluna: 'Backlog',
      prioridade: 'Média',
    );
    final repository = KanbanRepository(
      storageKey: 'fixture_kanban',
      dataSourceMode: DataSourceMode.local,
    );

    final primeiraCarga = await repository.loadCards(initialData: const [seed]);
    await repository.saveCards(const []);
    final aposExcluirTudo = await repository.loadCards(
      initialData: const [seed],
    );

    expect(primeiraCarga.single.id, seed.id);
    expect(aposExcluirTudo, isEmpty);
  });

  test('relatórios de demonstração são inseridos somente uma vez', () async {
    const seed = Relatorio(
      id: 'REL-001',
      titulo: 'Relatório inicial',
      descricao: 'Exemplo',
      tipo: 'Mensal',
      data: 'Jan/2026',
      autor: 'Coordenação',
      status: 'Publicado',
    );
    final repository = RelatorioRepository(
      storageKey: 'fixture_relatorios',
      dataSourceMode: DataSourceMode.local,
    );

    final primeiraCarga = await repository.loadRelatorios(
      initialData: const [seed],
    );
    await repository.saveRelatorios(const []);
    final aposExcluirTudo = await repository.loadRelatorios(
      initialData: const [seed],
    );

    expect(primeiraCarga.single.id, seed.id);
    expect(aposExcluirTudo, isEmpty);
  });
}
