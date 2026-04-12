import 'package:flutter/material.dart';
import '../../features/atividades/presentation/pages/atividades_page.dart';
import '../../features/carga_docente/presentation/pages/carga_docente_page.dart';
import '../../features/configuracoes/presentation/pages/configuracoes_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/demandas/presentation/pages/demandas_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/kanban/presentation/pages/kanban_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/relatorios/presentation/pages/relatorios_page.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.dashboard;

    switch (routeName) {
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.login),
          builder: (_) => const LoginPage(),
        );
      case AppRoutes.dashboard:
        return _shell(routeName, const DashboardPage());
      case AppRoutes.demandas:
        return _shell(routeName, const DemandasPage());
      case AppRoutes.kanban:
        return _shell(routeName, const KanbanPage());
      case AppRoutes.cargaDocente:
        return _shell(routeName, const CargaDocentePage());
      case AppRoutes.atividades:
        return _shell(routeName, const AtividadesPage());
      case AppRoutes.relatorios:
        return _shell(routeName, const RelatoriosPage());
      case AppRoutes.configuracoes:
        return _shell(routeName, const ConfiguracoesPage());
      default:
        return _shell(AppRoutes.dashboard, const DashboardPage());
    }
  }

  static MaterialPageRoute<void> _shell(String routeName, Widget page) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => HomeShellPage(
        currentRoute: routeName,
        child: page,
      ),
    );
  }
}
