import 'dart:ui' show Color;

import '../../../app/theme/sigad_colors.dart';
import 'relatorio_models.dart';

abstract final class RelatoriosService {
  static const List<String> statusDisponiveis = [
    'Todos',
    'Publicado',
    'Em revisão',
    'Agendado',
  ];

  static List<Relatorio> filtrarRelatorios({
    required List<Relatorio> relatorios,
    required String busca,
    required String filtroStatus,
  }) {
    return relatorios
        .where((relatorio) {
          final filtroMatch =
              filtroStatus == 'Todos' || relatorio.status == filtroStatus;
          final query = busca.trim().toLowerCase();
          final buscaMatch =
              query.isEmpty ||
              relatorio.titulo.toLowerCase().contains(query) ||
              relatorio.descricao.toLowerCase().contains(query) ||
              relatorio.autor.toLowerCase().contains(query);
          return filtroMatch && buscaMatch;
        })
        .toList(growable: false);
  }

  /// Texto baseado somente no registro selecionado; não afirma existir PDF.
  static String resumoCompartilhavel(Relatorio relatorio) => [
    'SIGAD — Resumo do relatório',
    'Identificador: ${relatorio.id}',
    'Título: ${relatorio.titulo}',
    'Tipo: ${relatorio.tipo}',
    'Descrição: ${relatorio.descricao}',
    'Autor: ${relatorio.autor}',
    'Data: ${relatorio.data}',
    'Situação: ${relatorio.status}',
  ].join('\n');

  static Color statusColor(String status) {
    switch (status) {
      case 'Publicado':
      case 'Disponível':
        return SigadColors.success;
      case 'Em revisão':
        return SigadColors.warning;
      case 'Agendado':
        return SigadColors.info;
      default:
        return SigadColors.muted;
    }
  }
}
