import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../models/navigation_item.dart';
import '../models/user_role.dart';

const List<NavigationItem> kNavigationItems = [
  NavigationItem(
    route: AppRoutes.dashboard,
    label: 'Visão geral',
    icon: Icons.dashboard_outlined,
  ),
  NavigationItem(
    route: AppRoutes.batePapo,
    label: 'Bate-papo',
    icon: Icons.forum_outlined,
  ),
  NavigationItem(
    route: AppRoutes.demandas,
    label: 'Demandas',
    icon: Icons.assignment_outlined,
    availableFor: {UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.professores,
    label: 'Professores',
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
    icon: Icons.view_kanban_outlined,
  ),
  NavigationItem(
    route: AppRoutes.aulasPraticas,
    label: 'Laboratórios',
    icon: Icons.science_outlined,
    availableFor: {UserRole.professor, UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Agenda',
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
    icon: Icons.fact_check_outlined,
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configurações',
    icon: Icons.settings_outlined,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
];
