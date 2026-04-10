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
    subtitle: 'Organize e priorize as solicitacoes ativas.',
  ),
  NavigationItem(
    route: AppRoutes.kanban,
    label: 'Kanban',
    icon: Icons.view_kanban_outlined,
    subtitle: 'Visualize o fluxo das demandas por etapa.',
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Carga docente',
    icon: Icons.schedule_outlined,
    subtitle: 'Acompanhe distribuicao e equilibrio de horas.',
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
    subtitle: 'Indicadores para tomada de decisao.',
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configuracoes',
    icon: Icons.settings_outlined,
    subtitle: 'Defina perfis, prazos e parametros.',
  ),
];
