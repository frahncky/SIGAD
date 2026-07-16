import 'package:flutter/material.dart';

import '../../features/calendario/presentation/pages/calendario_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/notas/presentation/pages/notas_page.dart';
import '../../features/redesign/presentation/pages/sigad_redesign_pages.dart';
import 'app_routes.dart';

/// Responsável por gerar as rotas do aplicativo SIGAD.
///
/// As páginas principais usam o sistema visual unificado do redesign. Login,
/// calendário e anotações permanecem em seus módulos próprios porque já foram
/// atualizados e possuem regras específicas de persistência e autenticação.
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
        return _shell(routeName, const SigadDashboardPage());
      case AppRoutes.batePapo:
        return _shell(routeName, const SigadChatPage());
      case AppRoutes.cargaDocente:
        return _shell(routeName, const SigadCargaDocentePage());
      case AppRoutes.demandas:
        return _shell(routeName, const SigadDemandasPage());
      case AppRoutes.kanban:
        return _shell(routeName, const SigadKanbanPage());
      case AppRoutes.aulasPraticas:
        return _shell(routeName, const SigadLaboratoriosPage());
      case AppRoutes.professores:
        return _shell(routeName, const SigadProfessoresPage());
      case AppRoutes.atividades:
        return _shell(routeName, const SigadAtividadesPage());
      case AppRoutes.relatorios:
        return _shell(routeName, const SigadRelatoriosPage());
      case AppRoutes.configuracoes:
        return _shell(routeName, const SigadConfiguracoesPage());
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

  static MaterialPageRoute<void> _shell(String routeName, Widget page) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => HomeShellPage(currentRoute: routeName, child: page),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.travel_explore_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'O endereço informado não corresponde a um módulo do SIGAD.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.dashboard,
                ),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Voltar à visão geral'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
