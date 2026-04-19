import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/atividades/data/contracts/atividade_api_contract.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/demandas/data/contracts/demanda_api_contract.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/kanban/data/contracts/kanban_api_contract.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';
import 'package:sigad/features/relatorios/data/contracts/relatorio_api_contract.dart';
import 'package:sigad/features/relatorios/domain/relatorio_models.dart';

void main() {
  group('API contracts', () {
    test('AtividadeDto faz roundtrip domain/json', () {
      const domain = Atividade(
        id: '#ATV-001',
        titulo: 'Titulo',
        descricao: 'Descricao',
        data: '19/04/2026',
        responsavel: 'Coordenação',
        status: 'Pendente',
      );

      final dto = AtividadeDto.fromDomain(domain);
      final fromJson = AtividadeDto.fromJson(dto.toJson()).toDomain();

      expect(fromJson.id, domain.id);
      expect(fromJson.titulo, domain.titulo);
    });

    test('DemandaDto faz roundtrip domain/json', () {
      const domain = Demanda(
        id: '#DEM-001',
        titulo: 'Titulo',
        descricao: 'Descricao',
        prioridade: 'Alta',
        statusLabel: 'Novo',
        proprietario: 'TI',
        prazo: '20/04/2026',
      );

      final dto = DemandaDto.fromDomain(domain);
      final fromJson = DemandaDto.fromJson(dto.toJson()).toDomain();

      expect(fromJson.id, domain.id);
      expect(fromJson.prioridade, domain.prioridade);
    });

    test('KanbanCardDto faz roundtrip domain/json', () {
      const domain = KanbanCardModel(
        id: 1,
        titulo: 'Card',
        coluna: 'Backlog',
        prioridade: 'Alta',
      );

      final dto = KanbanCardDto.fromDomain(domain);
      final fromJson = KanbanCardDto.fromJson(dto.toJson()).toDomain();

      expect(fromJson.id, domain.id);
      expect(fromJson.coluna, domain.coluna);
    });

    test('RelatorioDto faz roundtrip domain/json', () {
      const domain = Relatorio(
        id: 'REL-1',
        titulo: 'Titulo',
        descricao: 'Descricao',
        tipo: 'Mensal',
        data: 'Abr/2026',
        autor: 'Coordenação',
        status: 'Publicado',
        downloads: 10,
        compartilhamentos: 3,
      );

      final dto = RelatorioDto.fromDomain(domain);
      final fromJson = RelatorioDto.fromJson(dto.toJson()).toDomain();

      expect(fromJson.id, domain.id);
      expect(fromJson.downloads, domain.downloads);
    });
  });
}
