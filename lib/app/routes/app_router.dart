import '../../features/calendario/presentation/pages/calendario_page.dart';
import '../../features/notas/presentation/pages/notas_page.dart';
import 'package:flutter/material.dart';
import '../../features/atividades/presentation/pages/atividades_page.dart';
import '../../features/carga_docente/presentation/pages/carga_docente_page.dart';
import '../../features/carga_docente/domain/docente_models.dart';
import '../../features/carga_docente/presentation/pages/professores_page.dart';
import '../../features/configuracoes/presentation/pages/configuracoes_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/demandas/presentation/pages/demandas_page.dart';
import '../../features/bate_papo/presentation/pages/bate_papo_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/kanban/presentation/pages/kanban_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/relatorios/presentation/pages/relatorios_page.dart';
import '../../features/aulas_praticas/presentation/pages/aulas_praticas_page.dart';
import 'app_routes.dart';

/// Responsável por gerar as rotas do aplicativo SIGAD.
/// Inclui tratamento para rotas desconhecidas (404).
abstract final class AppRouter {
  /// Gera a rota baseada no nome informado.
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
      case AppRoutes.batePapo:
        return _shell(routeName, const BatePapoPage());
      case AppRoutes.cargaDocente:
        final docente = settings.arguments is Docente
            ? settings.arguments as Docente
            : null;
        return _shell(routeName, CargaDocentePage(docente: docente));
      case AppRoutes.demandas:
        return _shell(routeName, const DemandasPage());
      case AppRoutes.kanban:
        return _shell(routeName, const KanbanPage());
      case AppRoutes.aulasPraticas:
        return _shell(routeName, const AulasPraticasPage());
      case AppRoutes.professores:
        return _shell(routeName, const ProfessoresPage());
      case AppRoutes.atividades:
        return _shell(routeName, const AtividadesPage());
      case AppRoutes.relatorios:
        return _shell(routeName, const RelatoriosPage());
      case AppRoutes.configuracoes:
        return _shell(routeName, const ConfiguracoesPage());
      case AppRoutes.notas:
        return _shell(routeName, const NotasPage());
      case AppRoutes.calendario:
        return _shell(routeName, const CalendarioPage());
      default:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/404'),
          builder: (_) => const _NotFoundPage(),
        );
    }
  }

  /// Cria uma rota com o shell padrão do app.
  static MaterialPageRoute<void> _shell(String routeName, Widget page) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => HomeShellPage(currentRoute: routeName, child: page),
    );
  }
}

/// Página exibida para rotas não encontradas (404).
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: const Center(child: Text('404 - Página não encontrada')),
    );
  }
}
