import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';
import '../../../app/theme/sigad_icons.dart';
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
              icon: SigadIcons.livro,
              tone: SigadColors.brand,
            ),
            RoleMetric(
              label: 'Carga semanal',
              value: '32h',
              icon: SigadIcons.relogio,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Pendências',
              value: '3',
              icon: SigadIcons.pendente,
              tone: SigadColors.warning,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Confirmar plano de aula da semana',
              icon: SigadIcons.checklist,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Atualizar registro de atividades',
              icon: SigadIcons.checklist,
              tone: SigadColors.brand,
            ),
            PriorityItem(
              label: 'Validar horas complementares',
              icon: SigadIcons.cronometro,
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
              icon: SigadIcons.demanda,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Docentes ativos',
              value: '38',
              icon: SigadIcons.professor,
              tone: SigadColors.success,
            ),
            RoleMetric(
              label: 'Sprints em curso',
              value: '2',
              icon: SigadIcons.bandeira,
              tone: SigadColors.brand,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Priorizar demandas críticas da semana',
              icon: SigadIcons.prioridade,
              tone: SigadColors.risk,
            ),
            PriorityItem(
              label: 'Fechar horários dos docentes',
              icon: SigadIcons.balanca,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Aprovar tarefas do curso',
              icon: SigadIcons.kanban,
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
          tone: SigadColors.warning,
          metrics: [
            RoleMetric(
              label: 'Processos hoje',
              value: '18',
              icon: SigadIcons.pasta,
              tone: SigadColors.warning,
            ),
            RoleMetric(
              label: 'Solicitações',
              value: '11',
              icon: SigadIcons.documentoResumo,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Concluídos',
              value: '9',
              icon: SigadIcons.concluido,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Conferir documentos de laboratório',
              icon: SigadIcons.documento,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Atualizar status de protocolos',
              icon: SigadIcons.trocar,
              tone: SigadColors.warning,
            ),
            PriorityItem(
              label: 'Enviar relatório diário para coordenação',
              icon: SigadIcons.enviar,
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
              icon: SigadIcons.analise,
              tone: SigadColors.brandDark,
            ),
            RoleMetric(
              label: 'Demandas críticas',
              value: '4',
              icon: SigadIcons.alerta,
              tone: SigadColors.risk,
            ),
            RoleMetric(
              label: 'Cumprimento SLA',
              value: '92%',
              icon: SigadIcons.cronometro,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Validar plano de metas do mês',
              icon: SigadIcons.alvo,
              tone: SigadColors.brandDark,
            ),
            PriorityItem(
              label: 'Aprovar redistribuição de equipe',
              icon: SigadIcons.grupo,
              tone: SigadColors.info,
            ),
            PriorityItem(
              label: 'Revisar painel de desempenho institucional',
              icon: SigadIcons.tendencia,
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
              icon: SigadIcons.painel,
              tone: SigadColors.brand,
            ),
            RoleMetric(
              label: 'Usuários online',
              value: '42',
              icon: SigadIcons.grupo,
              tone: SigadColors.info,
            ),
            RoleMetric(
              label: 'Demandas no sistema',
              value: '24',
              icon: SigadIcons.caixaEntrada,
              tone: SigadColors.success,
            ),
          ],
          priorities: [
            PriorityItem(
              label: 'Realize login com um dos perfis',
              icon: SigadIcons.entrar,
              tone: SigadColors.brand,
            ),
            PriorityItem(
              label: 'Explore os módulos disponíveis',
              icon: SigadIcons.painel,
              tone: SigadColors.info,
            ),
          ],
          focus: ['Planejamento', 'Fluxo', 'Transparência'],
        );
    }
  }
}
