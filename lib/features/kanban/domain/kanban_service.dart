import 'dart:ui' show Color;

import '../../../app/theme/sigad_colors.dart';
import 'kanban_models.dart';

abstract final class KanbanService {
  static const List<String> colunas = [
    'Backlog',
    'Em Progresso',
    'Em Revisão',
    'Concluído',
  ];

  static const List<String> prioridades = ['Baixa', 'Média', 'Alta'];

  static Map<String, List<KanbanCardModel>> buildColunas(
    List<KanbanCardModel> cards,
  ) {
    return {
      for (final coluna in colunas)
        coluna: cards
            .where((card) => card.coluna == coluna)
            .toList(growable: false),
    };
  }

  static KanbanCardModel moverCard(KanbanCardModel card, String novaColuna) {
    return card.copyWith(coluna: novaColuna);
  }

  static int nextId(List<KanbanCardModel> cards) {
    if (cards.isEmpty) return 1;
    return cards.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  static String? validateTitulo(String titulo) {
    if (titulo.trim().isEmpty) return 'Informe o título da tarefa';
    return null;
  }

  static Color prioridadeColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return SigadColors.risk;
      case 'Média':
        return SigadColors.warning;
      default:
        return SigadColors.success;
    }
  }
}
