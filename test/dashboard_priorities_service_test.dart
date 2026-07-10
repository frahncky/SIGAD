import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/features/dashboard/domain/dashboard_priorities_service.dart';
import 'package:sigad/features/demandas/domain/demanda_models.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';

void main() {
  group('DashboardPrioritiesService', () {
    test('conta demandas atrasadas e altas em aberto', () {
      final demandas = [
        const Demanda(
          id: '#DEM-001',
          titulo: 'A',
          descricao: 'A',
          prioridade: 'Alta',
          statusLabel: 'Novo',
          proprietario: 'TI',
          prazo: '10/04/2026',
        ),
        const Demanda(
          id: '#DEM-002',
          titulo: 'B',
          descricao: 'B',
          prioridade: 'Alta',
          statusLabel: 'Concluído',
          proprietario: 'TI',
          prazo: '10/04/2026',
        ),
      ];

      final atrasadas = DashboardPrioritiesService.countDemandasAtrasadas(
        demandas,
        now: DateTime(2026, 4, 20),
      );
      final altas = DashboardPrioritiesService.countDemandasAltasAbertas(
        demandas,
      );

      expect(atrasadas, 1);
      expect(altas, 1);
    });

    test('conta cards por coluna e backlog alto', () {
      final cards = [
        const KanbanCardModel(
          id: 1,
          titulo: 'A',
          coluna: 'Em Revisão',
          prioridade: 'Alta',
        ),
        const KanbanCardModel(
          id: 2,
          titulo: 'B',
          coluna: 'Backlog',
          prioridade: 'Alta',
        ),
      ];

      expect(
        DashboardPrioritiesService.countKanbanByColumn(cards, 'Em Revisão'),
        1,
      );
      expect(DashboardPrioritiesService.countKanbanBacklogHigh(cards), 1);
    });
  });
}
