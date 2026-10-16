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

  static List<Relatorio> defaultRelatorios() {
    return const [
      Relatorio(
        id: '#REL-001',
        titulo: 'Mapeamento de Demandas do Período',
        descricao:
            'Análise consolidada de todas as solicitações recebidas no semestre 2026.1',
        tipo: 'Análise Geral',
        data: '15/04/2026',
        autor: 'Coordenação Acadêmica',
        status: 'Publicado',
      ),
      Relatorio(
        id: '#REL-002',
        titulo: 'Distribuição de Carga Horária Docente',
        descricao:
            'Relatório detalhado sobre equilíbrio de carga entre docentes',
        tipo: 'Recursos Humanos',
        data: '12/04/2026',
        autor: 'Departamento de RH',
        status: 'Publicado',
      ),
      Relatorio(
        id: '#REL-003',
        titulo: 'Indicadores de Desempenho - Q1 2026',
        descricao: 'Métricas de performance e KPIs do primeiro trimestre',
        tipo: 'Desempenho',
        data: '10/04/2026',
        autor: 'Gestão',
        status: 'Publicado',
      ),
      Relatorio(
        id: '#REL-004',
        titulo: 'Análise de Utilização de Laboratórios',
        descricao: 'Levantamento sobre uso de espaços e equipamentos',
        tipo: 'Infraestrutura',
        data: '18/04/2026',
        autor: 'Coordenação de Laboratórios',
        status: 'Em revisão',
      ),
      Relatorio(
        id: '#REL-005',
        titulo: 'Conformidade com Normas ISO',
        descricao:
            'Avaliação de conformidade dos processos com normas internacionais',
        tipo: 'Conformidade',
        data: '20/04/2026',
        autor: 'Auditoria Interna',
        status: 'Agendado',
      ),
    ];
  }

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
  ].join('\\n');

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
