import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../models/navigation_item.dart';
import '../models/user_role.dart';

const List<NavigationItem> kNavigationItems = [
  NavigationItem(
    route: AppRoutes.dashboard,
    label: 'Visão geral',
    subtitle: 'Indicadores, prioridades e atalhos',
    icon: Icons.dashboard_outlined,
  ),
  NavigationItem(
    route: AppRoutes.batePapo,
    label: 'Bate-papo',
    subtitle: 'Conversas individuais e em grupo',
    icon: Icons.forum_outlined,
  ),
  NavigationItem(
    route: AppRoutes.demandas,
    label: 'Demandas',
    subtitle: 'Solicitações, prazos e responsáveis',
    icon: Icons.assignment_outlined,
    availableFor: {UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.professores,
    label: 'Professores',
    subtitle: 'Cadastro, situação e carga atribuída',
    icon: Icons.school_outlined,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.kanban,
    label: 'Tarefas',
    subtitle: 'Quadro de acompanhamento das atividades',
    icon: Icons.view_kanban_outlined,
  ),
  NavigationItem(
    route: AppRoutes.aulasPraticas,
    label: 'Laboratórios',
    subtitle: 'Ocupação, reservas e conflitos',
    icon: Icons.science_outlined,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Carga docente',
    subtitle: 'Distribuição de aulas e atividades',
    icon: Icons.schedule_outlined,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.atividades,
    label: 'Atividades',
    subtitle: 'Ensino, pesquisa, extensão e gestão',
    icon: Icons.fact_check_outlined,
  ),
  NavigationItem(
    route: AppRoutes.relatorios,
    label: 'Relatórios',
    subtitle: 'Indicadores e exportações gerenciais',
    icon: Icons.analytics_outlined,
    availableFor: {
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configurações',
    subtitle: 'Conta, preferências e permissões',
    icon: Icons.settings_outlined,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
];
