import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../models/navigation_item.dart';
import '../models/user_role.dart';

const List<NavigationItem> kNavigationItems = [
  NavigationItem(
    route: AppRoutes.dashboard,
    label: 'Visao geral',
    icon: Icons.dashboard_outlined,
  ),
  NavigationItem(
    route: AppRoutes.demandas,
    label: 'Demandas',
    icon: Icons.assignment_outlined,
    availableFor: {UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.kanban,
    label: 'Kanban',
    icon: Icons.view_kanban_outlined,
  ),
  NavigationItem(
    route: AppRoutes.aulasPraticas,
    label: 'Aulas praticas',
    icon: Icons.science_outlined,
    subtitle: 'Controle de aulas praticas em laboratorios.',
    availableFor: {UserRole.professor, UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Carga docente',
    icon: Icons.schedule_outlined,
    availableFor: {UserRole.professor, UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.atividades,
    label: 'Atividades',
    icon: Icons.fact_check_outlined,
    subtitle: 'Registro estruturado de entregas e eventos.',
  ),
  NavigationItem(
    route: AppRoutes.relatorios,
    label: 'Relatorios',
    icon: Icons.insights_outlined,
    availableFor: {UserRole.coordenador, UserRole.servidorAdministrativo, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configuracoes',
    icon: Icons.settings_outlined,
    availableFor: {UserRole.chefeDepartamento},
  ),
];
