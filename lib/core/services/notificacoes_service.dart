import 'package:flutter/material.dart';

import '../../app/theme/sigad_icons.dart';
import '../models/user_role.dart';
import '../../features/atividades/data/atividade_repository.dart';
import '../../features/atividades/domain/atividade_models.dart';
import '../../features/demandas/data/demanda_repository.dart';
import '../../features/demandas/domain/demanda_models.dart';

/// Alerta derivado de um registro existente, nunca de exemplos estáticos.
class NotificacaoModel {
  const NotificacaoModel({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });

  final String titulo;
  final String subtitulo;
  final IconData icone;
}

/// Usa os dados disponíveis para o perfil atual. Sem registros, não inventa alertas.
abstract final class NotificacoesService {
  static Future<List<NotificacaoModel>> carregar(
    UserRole? role, {
    String? userName,
    DateTime? agora,
  }) async {
    if (role == null) return const [];

    final podeVerDemandas =
        role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final results = await Future.wait<Object>([
      if (podeVerDemandas) DemandaRepository().loadDemandas(),
      AtividadeRepository().loadAtividades(),
    ]);

    return porRole(
      role,
      demandas: podeVerDemandas ? results.first as List<Demanda> : const [],
      atividades: results.last as List<Atividade>,
      userName: userName,
      agora: agora,
    );
  }

  /// Separa as regras puras da leitura, permitindo testes sem rede e sem disco.
  static List<NotificacaoModel> porRole(
    UserRole? role, {
    List<Demanda> demandas = const [],
    List<Atividade> atividades = const [],
    String? userName,
    DateTime? agora,
  }) {
    if (role == null) return const [];

    final hoje = agora ?? DateTime.now();
    final diaAtual = DateTime(hoje.year, hoje.month, hoje.day);
    final notificacoes = <NotificacaoModel>[];

    if (role == UserRole.coordenador || role == UserRole.chefeDepartamento) {
      for (final demanda in demandas) {
        if (_concluido(demanda.statusLabel)) continue;
        final prazo = _parseData(demanda.prazo);
        if (prazo == null) continue;
        final dias = prazo.difference(diaAtual).inDays;
        if (dias > 2) continue;
        notificacoes.add(
          NotificacaoModel(
            titulo: demanda.titulo,
            subtitulo: dias < 0
                ? 'Demanda atrasada · prazo: ${demanda.prazo}'
                : dias == 0
                ? 'Demanda vence hoje'
                : 'Demanda vence em $dias dia${dias == 1 ? '' : 's'}',
            icone: dias < 0 ? SigadIcons.demandaAtrasada : SigadIcons.demanda,
          ),
        );
      }
    }

    // Atividades pessoais não são divulgadas a outros usuários.
    final nome = userName?.trim().toLowerCase() ?? '';
    if (nome.isNotEmpty) {
      for (final atividade in atividades) {
        if (_concluido(atividade.status) ||
            atividade.responsavel.trim().toLowerCase() != nome) {
          continue;
        }
        final prazo = _parseData(atividade.data);
        if (prazo == null) continue;
        final dias = prazo.difference(diaAtual).inDays;
        if (dias > 2) continue;
        notificacoes.add(
          NotificacaoModel(
            titulo: atividade.titulo,
            subtitulo: dias < 0
                ? 'Atividade atrasada · ${atividade.data}'
                : dias == 0
                ? 'Atividade prevista para hoje'
                : 'Atividade em $dias dia${dias == 1 ? '' : 's'}',
            icone: SigadIcons.eventoNota,
          ),
        );
      }
    }

    return List.unmodifiable(notificacoes);
  }

  static bool _concluido(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized.startsWith('conclu') ||
        normalized == 'finalizada' ||
        normalized == 'finalizado';
  }

  static DateTime? _parseData(String raw) {
    final parts = raw.trim().split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    final date = DateTime(y, m, d);
    if (date.day != d || date.month != m || date.year != y) return null;
    return date;
  }
}
