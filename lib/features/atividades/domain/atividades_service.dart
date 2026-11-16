import 'dart:ui' show Color;

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
        return SigadColors.warning;
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

  /// Opções do filtro de status, na ordem exibida.
  static const List<String> opcoesFiltro = [
    'Todas',
    'Pendente',
    'Agendada',
    'Em progresso',
    'Concluída',
  ];

  /// Formata a data no padrão gravado: `dd/MM/aaaa` ou, com hora,
  /// `dd/MM/aaaa - HH:mm`. A data é opcional; sem ela, grava texto vazio.
  static String formatarData(DateTime? data, {int? hora, int? minuto}) {
    if (data == null) return '';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final texto = '$dia/$mes/${data.year}';
    if (hora == null || minuto == null) return texto;
    final hh = hora.toString().padLeft(2, '0');
    final mm = minuto.toString().padLeft(2, '0');
    return '$texto - $hh:$mm';
  }

  /// Lê a hora (`HH:mm`) de um texto como `15/04/2026 - 10:30`.
  static ({int hora, int minuto})? horaDaAtividade(String texto) {
    final match = RegExp(r'(?<!\d)(\d{1,2}):(\d{2})(?!\d)').firstMatch(texto);
    if (match == null) return null;
    final hora = int.parse(match.group(1)!);
    final minuto = int.parse(match.group(2)!);
    if (hora > 23 || minuto > 59) return null;
    return (hora: hora, minuto: minuto);
  }

  static String? validarTituloAtividade(String titulo) =>
      titulo.trim().isEmpty ? 'Informe o título da atividade' : null;

  static String? validarDescricaoAtividade(String descricao) =>
      descricao.trim().isEmpty ? 'Informe a descrição da atividade' : null;

  static String? validarAtividade({
    required String titulo,
    required String descricao,
  }) {
    return validarTituloAtividade(titulo) ??
        validarDescricaoAtividade(descricao);
  }
}
