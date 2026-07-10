// Exemplo de como criar widgets customizados por role
// Este arquivo demonstra padrões para implementar diferentes UIs por perfil de usuário

import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/user_context_provider.dart';

/// Widget que renderiza conteúdo diferentes baseado no role do usuário
class RoleBasedWidget extends StatelessWidget {
  final Widget professorWidget;
  final Widget coordenadorWidget;
  final Widget servidorAdministrativoWidget;
  final Widget chefeWidget;
  final Widget? defaultWidget;

  const RoleBasedWidget({
    super.key,
    required this.professorWidget,
    required this.coordenadorWidget,
    required this.servidorAdministrativoWidget,
    required this.chefeWidget,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();

    if (!userContext.isAuthenticated) {
      return defaultWidget ?? const SizedBox();
    }

    switch (userContext.userRole) {
      case UserRole.professor:
        return professorWidget;
      case UserRole.coordenador:
        return coordenadorWidget;
      case UserRole.servidorAdministrativo:
        return servidorAdministrativoWidget;
      case UserRole.chefeDepartamento:
        return chefeWidget;
      default:
        return defaultWidget ?? const SizedBox();
    }
  }
}

/// Widget que renderiza conteúdo apenas para roles específicos
class RoleRestrictedWidget extends StatelessWidget {
  final Widget child;
  final Set<UserRole> allowedRoles;
  final Widget? restrictedWidget;

  const RoleRestrictedWidget({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.restrictedWidget,
  });

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();

    if (userContext.hasAnyRole(allowedRoles)) {
      return child;
    }

    return restrictedWidget ?? const SizedBox();
  }
}

// EXEMPLOS DE USO:

// ============================================================================
// EXEMPLO 1: Dashboard com seções diferentes por role
// ============================================================================
class DashboardExample extends StatelessWidget {
  const DashboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleBasedWidget(
      professorWidget: _ProfessorDashboard(),
      coordenadorWidget: _CoordDashboard(),
      servidorAdministrativoWidget: _AdminDashboard(),
      chefeWidget: _ChefeDashboard(),
    );
  }
}

class _ProfessorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Dashboard Professor'),
          const SizedBox(height: 16),
          // Mostrar minhas disciplinas
          _buildSection('Minhas Disciplinas'),
          // Mostrar carga horária
          _buildSection('Carga Horária'),
          // Mostrar próximas atividades
          _buildSection('Próximas Atividades'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
    );
  }
}

class _CoordDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Dashboard Coordenador'),
          const SizedBox(height: 16),
          // Mostrar status do curso
          _buildSection('Status do Curso'),
          // Mostrar demandas pendentes
          _buildSection('Demandas Pendentes'),
          // Mostrar relatório de docentes
          _buildSection('Relatório de Docentes'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Dashboard Servidor Administrativo'),
          const SizedBox(height: 16),
          // Mostrar documentos pendentes
          _buildSection('Documentos Pendentes'),
          // Mostrar atividades
          _buildSection('Atividades'),
          // Mostrar relatório de processamento
          _buildSection('Relatório de Processamento'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
    );
  }
}

class _ChefeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Dashboard Chefe do Departamento'),
          const SizedBox(height: 16),
          // Mostrar visão geral do departamento
          _buildSection('Visão Geral do Departamento'),
          // Mostrar KPIs
          _buildSection('KPIs e Métricas'),
          // Mostrar demandas críticas
          _buildSection('Demandas Críticas'),
          // Mostrar relatório geral
          _buildSection('Relatório Geral'),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),
    );
  }
}

// ============================================================================
// EXEMPLO 2: Seção visível apenas para coordenadores e chefes
// ============================================================================
class ConfigurationsExample extends StatelessWidget {
  const ConfigurationsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seção comum a todos
            const Text('Perfil do Usuário'),
            const SizedBox(height: 16),

            // Seção apenas para coordenador e chefe
            RoleRestrictedWidget(
              allowedRoles: {UserRole.coordenador, UserRole.chefeDepartamento},
              child: Column(
                children: [
                  const Divider(),
                  const Text('Configurações de Curso'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.blue.shade50,
                    child: const Text('Apenas para coordenadores e chefes'),
                  ),
                ],
              ),
            ),

            // Seção apenas para chefe
            RoleRestrictedWidget(
              allowedRoles: {UserRole.chefeDepartamento},
              child: Column(
                children: [
                  const Divider(),
                  const Text('Configurações do Departamento'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade50,
                    child: const Text('Apenas para o chefe do departamento'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXEMPLO 3: Botão que aparece apenas para certos roles
// ============================================================================
class AdministrativeActionExample extends StatelessWidget {
  const AdministrativeActionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ações Administrativas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão visible apenas para chefe
            RoleRestrictedWidget(
              allowedRoles: {UserRole.chefeDepartamento},
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.configuracoes),
                child: const Text('Configurar Departamento'),
              ),
            ),
            const SizedBox(height: 16),

            // Botão visible apenas para coordenador e chefe
            RoleRestrictedWidget(
              allowedRoles: {UserRole.coordenador, UserRole.chefeDepartamento},
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.demandas),
                child: const Text('Criar Demanda'),
              ),
            ),
            const SizedBox(height: 16),

            // Botão visível para todos
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.atividades),
              child: const Text('Ver Atividades'),
            ),
          ],
        ),
      ),
    );
  }
}
