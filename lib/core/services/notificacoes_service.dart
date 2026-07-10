import 'package:flutter/material.dart';

import '../models/user_role.dart';

/// Representa uma notificacao do sistema para o usuario ativo.
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

/// Fornece notificacoes relevantes de acordo com o [UserRole] do usuario ativo.
abstract final class NotificacoesService {
  static List<NotificacaoModel> porRole(UserRole? role) {
    return switch (role) {
      UserRole.professor => const [
        NotificacaoModel(
          titulo: 'Lembrete: Aula Algoritmos',
          subtitulo: 'Inicia em 15 min · Lab 02',
          icone: Icons.alarm_on_outlined,
        ),
        NotificacaoModel(
          titulo: 'Nova atividade atribuída',
          subtitulo: 'Entrega: 23/04/2026',
          icone: Icons.assignment_outlined,
        ),
      ],
      UserRole.coordenador => const [
        NotificacaoModel(
          titulo: '2 demandas aguardam revisão',
          subtitulo: 'Prazo: amanhã',
          icone: Icons.assignment_late_outlined,
        ),
        NotificacaoModel(
          titulo: 'Reunião de colegiado',
          subtitulo: 'Hoje, 14:00 · Sala 305',
          icone: Icons.groups_outlined,
        ),
      ],
      UserRole.servidorAdministrativo => const [
        NotificacaoModel(
          titulo: 'Processo 045/2026 pendente',
          subtitulo: 'Aguardando assinatura',
          icone: Icons.pending_actions_outlined,
        ),
        NotificacaoModel(
          titulo: 'Solicitação de laboratório',
          subtitulo: 'Lab 03, turno matutino',
          icone: Icons.science_outlined,
        ),
      ],
      UserRole.chefeDepartamento => const [
        NotificacaoModel(
          titulo: '3 demandas aguardam aprovação',
          subtitulo: 'Prazo encerrado em 2',
          icone: Icons.assignment_late_outlined,
        ),
        NotificacaoModel(
          titulo: 'Relatório mensal disponível',
          subtitulo: 'Março/2026 · Recursos humanos',
          icone: Icons.summarize_outlined,
        ),
        NotificacaoModel(
          titulo: 'Reunião de departamento',
          subtitulo: 'Amanhã, 10:00 · Auditório',
          icone: Icons.event_outlined,
        ),
      ],
      null => const [],
    };
  }
}
