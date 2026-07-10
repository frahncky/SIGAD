import 'package:flutter/material.dart';

import '../../../../app/theme/sigad_colors.dart';
import 'atividade_models.dart';

abstract final class AtividadesService {
  static const List<String> statusAtividade = [
    'Concluída',
    'Em progresso',
    'Agendada',
    'Pendente',
  ];

  static const List<String> responsaveis = [
    'Coordenação',
    'Gestão',
    'TI',
    'RH',
    'Auditoria',
    'Comunicação',
  ];

  static List<Atividade> defaultAtividades() {
    return const [
      Atividade(
        id: '#ATV-001',
        titulo: 'Entrega de levantamento de demandas',
        descricao: 'Documento consolidado com todas as solicitações do período',
        data: '15/04/2026 - 10:30',
        responsavel: 'Coordenação',
        status: 'Concluída',
      ),
      Atividade(
        id: '#ATV-002',
        titulo: 'Reunião de validação de requisitos',
        descricao: 'Apresentação dos requisitos para stakeholders',
        data: '18/04/2026 - 14:00',
        responsavel: 'Gestão',
        status: 'Concluída',
      ),
      Atividade(
        id: '#ATV-003',
        titulo: 'Implementação de sistema de priorização',
        descricao: 'Desenvolvimento da matriz de priorização',
        data: '22/04/2026 - 09:00',
        responsavel: 'TI',
        status: 'Em progresso',
      ),
      Atividade(
        id: '#ATV-004',
        titulo: 'Treinamento de usuários',
        descricao: 'Capacitação de 150 usuários no novo sistema',
        data: '28/04/2026 - 08:00',
        responsavel: 'RH',
        status: 'Agendada',
      ),
      Atividade(
        id: '#ATV-005',
        titulo: 'Auditoria de conformidade',
        descricao: 'Verificação de conformidade com normas ISO',
        data: '05/05/2026 - 13:00',
        responsavel: 'Auditoria',
        status: 'Agendada',
      ),
      Atividade(
        id: '#ATV-006',
        titulo: 'Publicação de resultados',
        descricao: 'Divulgação dos resultados para a comunidade acadêmica',
        data: '10/05/2026',
        responsavel: 'Comunicação',
        status: 'Pendente',
      ),
    ];
  }

  static List<Atividade> filtrarAtividades({
    required List<Atividade> atividades,
    required String busca,
    required String filtro,
  }) {
    return atividades
        .where((atividade) {
          final filtroMatch = filtro == 'Todas' || atividade.status == filtro;
          final query = busca.trim().toLowerCase();
          final buscaMatch =
              query.isEmpty ||
              atividade.titulo.toLowerCase().contains(query) ||
              atividade.descricao.toLowerCase().contains(query) ||
              atividade.responsavel.toLowerCase().contains(query);
          return filtroMatch && buscaMatch;
        })
        .toList(growable: false);
  }

  static int countConcluidas(List<Atividade> atividades) {
    return atividades
        .where((atividade) => atividade.status == 'Concluída')
        .length;
  }

  static int countPendentes(List<Atividade> atividades) {
    return atividades
        .where((atividade) => atividade.status == 'Pendente')
        .length;
  }

  static Color statusColor(String status) {
    switch (status) {
      case 'Concluída':
        return SigadColors.success;
      case 'Em progresso':
        return SigadColors.info;
      case 'Agendada':
        return SigadColors.warning;
      case 'Pendente':
        return SigadColors.accent;
      default:
        return SigadColors.muted;
    }
  }

  static String gerarProximoIdAtividade(List<Atividade> atividades) {
    var maiorId = 0;

    for (final atividade in atividades) {
      final numero = int.tryParse(
        atividade.id.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (numero != null && numero > maiorId) {
        maiorId = numero;
      }
    }

    final proximoId = maiorId + 1;
    return '#ATV-${proximoId.toString().padLeft(3, '0')}';
  }

  static String dataPadraoNovaAtividade() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  static String? validarAtividade({
    required String titulo,
    required String descricao,
  }) {
    if (titulo.trim().isEmpty) {
      return 'Informe o título da atividade';
    }

    if (descricao.trim().isEmpty) {
      return 'Informe a descrição da atividade';
    }

    return null;
  }
}
