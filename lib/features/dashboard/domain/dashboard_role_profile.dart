import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';
import '../../../core/models/user_role.dart';

class RoleMetric {
  const RoleMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;
}

class PriorityItem {
  const PriorityItem({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;
}

class RoleProfile {
  const RoleProfile({
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.metrics,
    required this.priorities,
    required this.focus,
  });

  final String title;
  final String subtitle;
  final Color tone;
  final List<RoleMetric> metrics;
  final List<PriorityItem> priorities;
  final List<String> focus;

  static RoleProfile fromRole(UserRole? role) {
    switch (role) {
      case UserRole.professor:
        return const RoleProfile(
          title: 'Perfil Professor',
          subtitle: 'Acompanhe sua carga, aulas e demandas acadêmicas.',
          tone: SigadColors.brand,
          metrics: [
            RoleMetric(
              label: 'Disciplinas',
              value: '5',
              icon: Icons.menu_book_outlined,
              tone: SigadColors.brand,
            ),
            RoleMetric(
              label: 'Carga semanal',
              value: '32h',
              icon: Icons.schedule_outlined,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Pendências',
              value: '3',
              icon: Icons.pending_actions_outlined,
              tone: SigadColors.warning,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Confirmar plano de aula da semana',
              icon: Icons.checklist_outlined,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Atualizar registro de atividades',
              icon: Icons.fact_check_outlined,
              tone: SigadColors.brand,
            ),
            PriorityItem(
              label: 'Validar horas complementares',
              icon: Icons.timer_outlined,
              tone: SigadColors.warning,
            ),
          ],
          focus: ['Aulas', 'Carga', 'Atividades'],
        );
      case UserRole.coordenador:
        return const RoleProfile(
          title: 'Perfil Coordenador',
          subtitle: 'Gerencie demandas do curso e distribua responsabilidades.',
          tone: SigadColors.info,
          metrics: [
            RoleMetric(
              label: 'Demandas abertas',
              value: '24',
              icon: Icons.assignment_outlined,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Docentes ativos',
              value: '38',
              icon: Icons.school_outlined,
              tone: SigadColors.success,
            ),
            RoleMetric(
              label: 'Sprints em curso',
              value: '2',
              icon: Icons.flag_outlined,
              tone: SigadColors.brand,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Priorizar demandas críticas da semana',
              icon: Icons.priority_high_outlined,
              tone: SigadColors.risk,
            ),
            PriorityItem(
              label: 'Fechar horários dos docentes',
              icon: Icons.balance_outlined,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Aprovar tarefas do curso',
              icon: Icons.view_kanban_outlined,
              tone: SigadColors.brand,
            ),
          ],
          focus: ['Demandas', 'Tarefas', 'Relatórios'],
        );
      case UserRole.servidorAdministrativo:
        return const RoleProfile(
          title: 'Perfil Servidor Administrativo',
          subtitle:
              'Mantenha processos operacionais e fluxos documentais em dia.',
          tone: SigadColors.accent,
          metrics: [
            RoleMetric(
              label: 'Processos hoje',
              value: '18',
              icon: Icons.folder_open_outlined,
              tone: SigadColors.accent,
            ),
            RoleMetric(
              label: 'Solicitações',
              value: '11',
              icon: Icons.request_page_outlined,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Concluídos',
              value: '9',
              icon: Icons.task_alt_outlined,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Conferir documentos de laboratório',
              icon: Icons.description_outlined,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Atualizar status de protocolos',
              icon: Icons.swap_horiz_outlined,
              tone: SigadColors.accent,
            ),
            PriorityItem(
              label: 'Enviar relatório diário para coordenação',
              icon: Icons.send_outlined,
              tone: SigadColors.brand,
            ),
          ],
          focus: ['Protocolos', 'Relatórios', 'Atendimento'],
        );
      case UserRole.chefeDepartamento:
        return const RoleProfile(
          title: 'Chefe de Departamento',
          subtitle: 'Visão estratégica de governança, desempenho e alocação.',
          tone: SigadColors.brandDark,
          metrics: [
            RoleMetric(
              label: 'Indicadores-chave',
              value: '12',
              icon: Icons.analytics_outlined,
              tone: SigadColors.brandDark,
            ),
            RoleMetric(
              label: 'Demandas críticas',
              value: '4',
              icon: Icons.warning_amber_outlined,
              tone: SigadColors.risk,
            ),
            RoleMetric(
              label: 'Cumprimento SLA',
              value: '92%',
              icon: Icons.av_timer_outlined,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Validar plano de metas do mês',
              icon: Icons.track_changes_outlined,
              tone: SigadColors.brandDark,
            ),
            PriorityItem(
              label: 'Aprovar redistribuição de equipe',
              icon: Icons.groups_outlined,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Revisar painel de desempenho institucional',
              icon: Icons.query_stats_outlined,
              tone: SigadColors.success,
            ),
          ],
          focus: ['Estratégia', 'Governança', 'KPIs'],
        );
      default:
        return const RoleProfile(
          title: 'Visão geral do SIGAD',
          subtitle:
              'Selecione um perfil para ver atalhos e prioridades personalizadas.',
          tone: SigadColors.brand,
          metrics: [
            RoleMetric(
              label: 'Módulos ativos',
              value: '6',
              icon: Icons.dashboard_outlined,
              tone: SigadColors.brand,
            ),
            RoleMetric(
              label: 'Usuários online',
              value: '42',
              icon: Icons.groups_outlined,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Demandas no sistema',
              value: '24',
              icon: Icons.inbox_outlined,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Realize login com um dos perfis',
              icon: Icons.login_outlined,
              tone: SigadColors.brand,
            ),
            PriorityItem(
              label: 'Explore os módulos disponíveis',
              icon: Icons.apps_outlined,
              tone: SigadColors.info,
            ),
          ],
          focus: ['Planejamento', 'Fluxo', 'Transparência'],
        );
    }
  }
}
