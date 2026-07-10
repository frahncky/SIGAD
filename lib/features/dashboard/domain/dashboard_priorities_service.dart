import '../../demandas/domain/demanda_models.dart';
import '../../kanban/domain/kanban_models.dart';

abstract final class DashboardPrioritiesService {
  static int countDemandasAtrasadas(List<Demanda> demandas, {DateTime? now}) {
    final hoje = now ?? DateTime.now();
    final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);

    var total = 0;
    for (final demanda in demandas) {
      final status = demanda.statusLabel.toLowerCase();
      if (status == 'concluido' || status == 'concluído') continue;

      final prazo = _parseDate(demanda.prazo);
      if (prazo != null && prazo.isBefore(inicioDia)) {
        total++;
      }
    }

    return total;
  }

  static int countDemandasAltasAbertas(List<Demanda> demandas) {
    var total = 0;
    for (final demanda in demandas) {
      final prioridade = demanda.prioridade.toLowerCase();
      final status = demanda.statusLabel.toLowerCase();
      if (prioridade == 'alta' &&
          status != 'concluido' &&
          status != 'concluído') {
        total++;
      }
    }
    return total;
  }

  static int countKanbanByColumn(List<KanbanCardModel> cards, String column) {
    final target = column.toLowerCase();
    return cards.where((card) => card.coluna.toLowerCase() == target).length;
  }

  static int countKanbanBacklogHigh(List<KanbanCardModel> cards) {
    return cards
        .where(
          (card) =>
              card.coluna.toLowerCase() == 'backlog' &&
              card.prioridade.toLowerCase() == 'alta',
        )
        .length;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }
}
