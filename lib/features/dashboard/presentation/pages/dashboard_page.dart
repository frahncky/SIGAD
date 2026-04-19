import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../demandas/data/demanda_repository.dart';
import '../../../kanban/data/kanban_repository.dart';
import '../../domain/dashboard_priorities_service.dart';
import '../../domain/dashboard_role_profile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final profile = RoleProfile.fromRole(role);
    final userName = userContext.currentUser?.name ?? 'Usuário';

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
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Atalhos do seu perfil',
                    icon: Icons.apps_outlined,
                  ),
                  const SizedBox(height: 12),
                  _ModuleGrid(modules: availableModules),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Prioridades',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 12),
                  _DynamicPriorityList(
                    role: role,
                    fallbackItems: profile.priorities,
                  ),
                  const SizedBox(height: 16),
                  _FocusChips(items: profile.focus),
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
  });

  final RoleProfile profile;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width >= 1200;

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

    final compactIndicators = Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: profile.metrics
          .take(3)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) {
              final index = entry.key;
              final metric = entry.value;
              const labels = ['Indicadores', 'Demandas', 'SLA'];
              final compactLabel = labels[index.clamp(0, labels.length - 1)];
              return Container(
              constraints: const BoxConstraints(minWidth: 94),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    compactLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            );
            },
          )
          .toList(),
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
    final subtitle = item.subtitle?.trim();

    return Material(
      color: SigadColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SigadColors.divider),
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
                  style: textTheme.bodySmall?.copyWith(color: SigadColors.muted),
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

class _PriorityList extends StatelessWidget {
  const _PriorityList({required this.items});

  final List<PriorityItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SigadColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SigadColors.divider),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: item.tone),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DynamicPriorityList extends StatefulWidget {
  const _DynamicPriorityList({
    required this.role,
    required this.fallbackItems,
  });

  final UserRole? role;
  final List<PriorityItem> fallbackItems;

  @override
  State<_DynamicPriorityList> createState() => _DynamicPriorityListState();
}

class _DynamicPriorityListState extends State<_DynamicPriorityList> {
  final DemandaRepository _demandaRepository = DemandaRepository();
  final KanbanRepository _kanbanRepository = KanbanRepository();
  late Future<List<PriorityItem>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = _buildDynamicItems();
  }

  Future<List<PriorityItem>> _buildDynamicItems() async {
    final demandas = await _demandaRepository.loadDemandas();
    final kanban = await _kanbanRepository.loadCards();

    final items = <PriorityItem>[];

    final demandasAtrasadas = DashboardPrioritiesService.countDemandasAtrasadas(demandas);
    if (demandasAtrasadas > 0) {
      items.add(
        PriorityItem(
          label: 'Resolver $demandasAtrasadas demanda(s) em atraso',
          icon: Icons.warning_amber_outlined,
          tone: SigadColors.risk,
        ),
      );
    }

    final demandasAltasAbertas = DashboardPrioritiesService.countDemandasAltasAbertas(demandas);
    if (demandasAltasAbertas > 0) {
      items.add(
        PriorityItem(
          label: 'Tratar $demandasAltasAbertas demanda(s) de alta prioridade',
          icon: Icons.priority_high_outlined,
          tone: SigadColors.warning,
        ),
      );
    }

    final cardsEmRevisao = DashboardPrioritiesService.countKanbanByColumn(kanban, 'Em Revisão');
    if (cardsEmRevisao > 0) {
      items.add(
        PriorityItem(
          label: 'Validar $cardsEmRevisao card(s) em revisão no Kanban',
          icon: Icons.rate_review_outlined,
          tone: SigadColors.info,
        ),
      );
    }

    final cardsBacklogAlto = DashboardPrioritiesService.countKanbanBacklogHigh(kanban);
    if (cardsBacklogAlto > 0) {
      items.add(
        PriorityItem(
          label: 'Priorizar $cardsBacklogAlto card(s) críticos do backlog',
          icon: Icons.view_kanban_outlined,
          tone: SigadColors.brand,
        ),
      );
    }

    if (items.isEmpty) {
      return widget.fallbackItems;
    }

    return items.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PriorityItem>>(
      future: _futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
          );
        }

        final items = snapshot.data ?? widget.fallbackItems;
        return _PriorityList(items: items);
      },
    );
  }
}

class _FocusChips extends StatelessWidget {
  const _FocusChips({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Chip(
              label: Text(item),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [SigadColors.canvas, SigadColors.surfaceAlt],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

