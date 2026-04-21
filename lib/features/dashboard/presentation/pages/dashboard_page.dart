import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../configuracoes/data/configuracoes_repository.dart';
import '../../../configuracoes/domain/configuracoes_models.dart';
import '../../domain/dashboard_role_profile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final profile = RoleProfile.fromRole(role);
    final userName = userContext.currentUser?.name ?? 'Usuário';
    final currentUserId = userContext.currentUser?.id ?? '';

    final availableModules = kNavigationItems
        .where((item) => role == null || item.isAvailableFor(role))
        .where((item) => item.route != AppRoutes.dashboard)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        return Stack(
          children: [
            const _AmbientBackground(),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 8 : 10,
                isWide ? 20 : 16,
                isWide ? 8 : 10,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroPanel(
                    profile: profile,
                    userName: userName,
                    currentUserId: currentUserId,
                    role: role,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Atalhos do seu perfil',
                    icon: Icons.apps_outlined,
                  ),
                  const SizedBox(height: 12),
                  _ModuleGrid(modules: availableModules),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.profile,
    required this.userName,
    required this.currentUserId,
    required this.role,
  });

  final RoleProfile profile;
  final String userName;
  final String currentUserId;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 1200;
    final labels = _labelsPorPerfil();

    final headerText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $userName',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final compactIndicators = FutureBuilder<ConfiguracoesData?>(
      future: ConfiguracoesRepository().load(),
      builder: (context, snapshot) {
        final indicadores = snapshot.hasData
            ? _agendaInsights(snapshot.data!.agendaCompromissos, labels)
            : [
                _HeroInsight(value: '--', label: labels.primeiro),
                _HeroInsight(value: '0', label: labels.segundo),
                _HeroInsight(value: '0', label: labels.terceiro),
              ];

        return Row(
          children: [
            for (var i = 0; i < indicadores.length; i++) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        indicadores[i].value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        indicadores[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < indicadores.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 34 : 24,
        vertical: isWide ? 22 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            profile.tone,
            profile.tone.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: profile.tone.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerText,
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.topCenter,
            child: compactIndicators,
          ),
        ],
      ),
    );
  }

  List<_HeroInsight> _agendaInsights(List<CompromissoAgenda> compromissos, _InsightLabels labels) {
    final agora = DateTime.now();
    final doUsuario = compromissos
        .where(
          (item) => item.destinatarioUserId.isEmpty || item.destinatarioUserId == currentUserId,
        )
        .toList(growable: false);

    final pendentes = doUsuario.where((item) => item.statusConvite == StatusConviteAgenda.pendente).length;

    final deHoje = doUsuario.where((item) {
      if (item.statusConvite == StatusConviteAgenda.recusado) return false;
      final inicio = DateTime.tryParse(item.inicioIso);
      if (inicio == null) return false;
      return inicio.year == agora.year && inicio.month == agora.month && inicio.day == agora.day;
    }).length;

    final futuros = doUsuario
        .where((item) {
          if (item.statusConvite == StatusConviteAgenda.recusado) return false;
          final inicio = DateTime.tryParse(item.inicioIso);
          if (inicio == null) return false;
          return !inicio.isBefore(agora);
        })
        .toList(growable: false)
      ..sort((a, b) {
        final ai = DateTime.tryParse(a.inicioIso) ?? DateTime(2100);
        final bi = DateTime.tryParse(b.inicioIso) ?? DateTime(2100);
        return ai.compareTo(bi);
      });

    final proximo = futuros.isEmpty ? null : DateTime.tryParse(futuros.first.inicioIso);

    return [
      _HeroInsight(
        value: proximo == null ? '--' : _formatarHoraMinuto(proximo),
        label: labels.primeiro,
      ),
      _HeroInsight(
        value: '$pendentes',
        label: labels.segundo,
      ),
      _HeroInsight(
        value: '$deHoje',
        label: labels.terceiro,
      ),
    ];
  }

  _InsightLabels _labelsPorPerfil() {
    switch (role) {
      case UserRole.professor:
        return const _InsightLabels('Aula', 'Convites', 'Hoje');
      case UserRole.coordenador:
        return const _InsightLabels('Reuniao', 'Convites', 'Hoje');
      case UserRole.servidorAdministrativo:
        return const _InsightLabels('Agenda', 'Convites', 'Hoje');
      case UserRole.chefeDepartamento:
        return const _InsightLabels('Demandas', 'Convites', 'Hoje');
      default:
        return const _InsightLabels('Proximo', 'Pendentes', 'Hoje');
    }
  }

  String _formatarHoraMinuto(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}

class _HeroInsight {
  const _HeroInsight({required this.value, required this.label});

  final String value;
  final String label;
}

class _InsightLabels {
  const _InsightLabels(this.primeiro, this.segundo, this.terceiro);

  final String primeiro;
  final String segundo;
  final String terceiro;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: SigadColors.brand, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});

  final List<NavigationItem> modules;

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 102,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _ModuleCard(item: modules[index]),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.item});

  final NavigationItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = Theme.of(context).dividerColor;
    final subtitle = item.subtitle?.trim();

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: SigadColors.brand.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: SigadColors.brand, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
