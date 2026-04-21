import 'package:flutter/material.dart';

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

  static List<KanbanCardModel> defaultCards() {
    return [
      KanbanCardModel(id: 1, titulo: 'Revisão de inventário', coluna: 'Backlog', prioridade: 'Alta'),
      KanbanCardModel(id: 2, titulo: 'Mapear demandas', coluna: 'Em Progresso', prioridade: 'Alta'),
      KanbanCardModel(id: 3, titulo: 'Padronizar formulários', coluna: 'Em Revisão', prioridade: 'Média'),
      KanbanCardModel(id: 4, titulo: 'Auditoria de estágio', coluna: 'Em Revisão', prioridade: 'Média'),
      KanbanCardModel(id: 5, titulo: 'Relatório de labs', coluna: 'Concluído', prioridade: 'Baixa'),
      KanbanCardModel(id: 6, titulo: 'Planejar semestre', coluna: 'Backlog', prioridade: 'Alta'),
      KanbanCardModel(id: 7, titulo: 'Revisar documentação', coluna: 'Em Progresso', prioridade: 'Média'),
    ];
  }

  static Map<String, List<KanbanCardModel>> buildColunas(List<KanbanCardModel> cards) {
    return {
      for (final coluna in colunas)
        coluna: cards.where((card) => card.coluna == coluna).toList(growable: false),
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
    if (titulo.trim().isEmpty) return 'Informe o título do card';
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
