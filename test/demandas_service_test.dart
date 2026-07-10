import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/demandas/domain/demandas_service.dart';

void main() {
  group('DemandasService', () {
    test('filtra e ordena demandas por prioridade', () {
      final demandas = [
        const Demanda(
          id: '#DEM-002',
          titulo: 'B',
          descricao: 'x',
          prioridade: 'Média',
          statusLabel: 'Novo',
          proprietario: 'TI',
          prazo: '20/04/2026',
        ),
        const Demanda(
          id: '#DEM-001',
          titulo: 'A',
          descricao: 'x',
          prioridade: 'Alta',
          statusLabel: 'Novo',
          proprietario: 'TI',
          prazo: '15/04/2026',
        ),
      ];

      final filtradas = DemandasService.filtrarDemandas(
        demandas: demandas,
        busca: '',
        filtroStatus: 'Novo',
        filtroPrioridade: 'Todas',
      );
      final ordenadas = DemandasService.ordenarDemandas(
        filtradas,
        'Prioridade',
      );

      expect(ordenadas.first.id, '#DEM-001');
    });

    test('valida e gera próximo id', () {
      expect(
        DemandasService.validarDemanda(titulo: '', descricao: 'x'),
        'Informe o título da demanda',
      );
      expect(
        DemandasService.gerarProximoIdDemanda(const [
          Demanda(
            id: '#DEM-009',
            titulo: 'x',
            descricao: 'x',
            prioridade: 'Alta',
            statusLabel: 'Novo',
            proprietario: 'TI',
            prazo: '01/01/2026',
          ),
        ]),
        '#DEM-010',
      );
    });

    test('remove opções repetidas preservando ordem e primeiro item', () {
      final opcoes = DemandasService.opcoesUnicas(const [
        'Todas',
        'Novo',
        'Novo',
        'Revisão',
        '',
      ], primeiro: 'Todas');

      expect(opcoes, const ['Todas', 'Novo', 'Revisão']);
    });
  });
}
