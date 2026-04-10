import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../models/navigation_item.dart';

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

  ),
  NavigationItem(
    route: AppRoutes.kanban,
    label: 'Kanban',
    icon: Icons.view_kanban_outlined,
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Carga docente',
    icon: Icons.schedule_outlined,

  ),
  NavigationItem(
    route: AppRoutes.atividades,
    label: 'Atividades',
    icon: Icons.fact_check_outlined,
    subtitle: 'Registro estruturado de entregas e eventos.',
  ),
  NavigationItem(
    route: AppRoutes.relatorios,
    label: 'Relatórios',
    icon: Icons.insights_outlined,
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configurações',
    icon: Icons.settings_outlined,
  ),
];
