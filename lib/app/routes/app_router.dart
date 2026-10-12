import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/user_context_provider.dart';

import '../../features/atividades/presentation/pages/atividades_page.dart';
import '../../features/aulas_praticas/presentation/pages/aulas_praticas_page.dart';
import '../../features/bate_papo/presentation/pages/bate_papo_page.dart';
import '../../features/calendario/presentation/pages/calendario_page.dart';
import '../../features/carga_docente/domain/docente_models.dart';
import '../../features/carga_docente/presentation/pages/carga_docente_page.dart';
import '../../features/carga_docente/presentation/pages/professores_page.dart';
import '../../features/configuracoes/presentation/pages/configuracoes_page.dart';
import '../../features/demandas/presentation/pages/demandas_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/home/presentation/pages/home_shell_page.dart';
import '../../features/kanban/presentation/pages/kanban_page.dart';
import '../../features/login/presentation/pages/login_page.dart';
import '../../features/mais/presentation/pages/mais_page.dart';
import '../../features/notas/presentation/pages/notas_page.dart';
import '../../features/redesign/presentation/pages/module_workspace_page.dart';
import '../../features/redesign/presentation/pages/sigad_redesign_pages.dart';
import '../../features/mural/presentation/pages/mural_page.dart';
import '../../features/relatorios/presentation/pages/relatorios_page.dart';
import '../theme/sigad_icon.dart';
import '../theme/sigad_icons.dart';
import 'app_routes.dart';

/// Gera as rotas do SIGAD e preserva os fluxos funcionais existentes.
///
/// Cada módulo apresenta a operação funcional. As visões gerenciais
/// permanecem reservadas até que sejam integradas a dados reais.
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
        return _workspace(
          routeName,
          overview: const SigadDashboardPage(),
          operation: const DashboardPage(),
          operationLabel: 'Painel operacional',
        );
      case AppRoutes.batePapo:
        return _workspace(
          routeName,
          overview: const SigadChatPage(),
          operation: const BatePapoPage(),
          operationLabel: 'Conversas',
        );
      case AppRoutes.cargaDocente:
        final docente = settings.arguments is Docente
            ? settings.arguments as Docente
            : null;
        return _workspace(
          routeName,
          overview: const SigadCargaDocentePage(),
          operation: CargaDocentePage(docente: docente),
          operationLabel: 'Distribuição',
        );
      case AppRoutes.demandas:
        return _workspace(
          routeName,
          overview: const SigadDemandasPage(),
          operation: const DemandasPage(),
          operationLabel: 'Gerenciar',
        );
      case AppRoutes.kanban:
        return _workspace(
          routeName,
          overview: const SigadKanbanPage(),
          operation: const KanbanPage(),
          operationLabel: 'Quadro operacional',
        );
      case AppRoutes.aulasPraticas:
        return _workspace(
          routeName,
          overview: const SigadLaboratoriosPage(),
          operation: const AulasPraticasPage(),
          operationLabel: 'Reservas',
        );
      case AppRoutes.professores:
        return _workspace(
          routeName,
          overview: const SigadProfessoresPage(),
          operation: const ProfessoresPage(),
          operationLabel: 'Cadastro e horários',
        );
      case AppRoutes.atividades:
        return _workspace(
          routeName,
          overview: const SigadAtividadesPage(),
          operation: const AtividadesPage(),
          operationLabel: 'Acompanhamento',
        );
      case AppRoutes.relatorios:
        return _workspace(
          routeName,
          overview: const SigadRelatoriosPage(),
          operation: const RelatoriosPage(),
          operationLabel: 'Consultar e exportar',
        );
      case AppRoutes.configuracoes:
        return _workspace(
          routeName,
          overview: const SigadConfiguracoesPage(),
          operation: const ConfiguracoesPage(),
          operationLabel: 'Preferências avançadas',
        );
      case AppRoutes.notas:
        return _shell(routeName, const NotasPage());
      case AppRoutes.calendario:
        return _shell(routeName, const CalendarioPage());
      case AppRoutes.mais:
        return _shell(routeName, const MaisPage());
      case AppRoutes.mural:
        return _shell(routeName, const MuralPage());
      default:
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/404'),
          builder: (_) => const _NotFoundPage(),
        );
    }
  }

  static MaterialPageRoute<void> _workspace(
    String routeName, {
    required Widget overview,
    required Widget operation,
    required String operationLabel,
  }) {
    return _shell(
      routeName,
      ModuleWorkspacePage(
        overview: overview,
        operation: operation,
        operationLabel: operationLabel,
      ),
    );
  }

  static MaterialPageRoute<void> _shell(String routeName, Widget page) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: routeName),
      builder: (_) => Consumer<UserContextProvider>(
        builder: (context, userContext, _) => userContext.isAuthenticated
            ? HomeShellPage(currentRoute: routeName, child: page)
            : const LoginPage(),
      ),
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
              SigadIcon(
                SigadIcons.globo,
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
                icon: const SigadIcon(SigadIcons.inicio),
                label: const Text('Voltar à visão geral'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
