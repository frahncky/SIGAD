import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../atividades/data/atividade_repository.dart';
import '../../../atividades/domain/atividade_models.dart';
import '../../../atividades/domain/atividades_service.dart';
import '../../../configuracoes/data/configuracoes_repository.dart';
import '../../../configuracoes/domain/configuracoes_models.dart';
import '../../../demandas/data/demanda_repository.dart';
import '../../../demandas/domain/demanda_models.dart';
import '../../../demandas/domain/demandas_service.dart';
import '../../../kanban/data/kanban_repository.dart';
import '../../../kanban/domain/kanban_models.dart';
import '../../../kanban/domain/kanban_service.dart';
import '../../domain/dashboard_priorities_service.dart';
import '../../domain/dashboard_role_profile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadDashboardData();
  }

  Future<_DashboardData> _loadDashboardData() async {
    final results = await Future.wait<Object>([
      DemandaRepository().loadDemandas(),
      KanbanRepository().loadCards(),
      AtividadeRepository().loadAtividades(),
    ]);

    final storedDemandas = results[0] as List<Demanda>;
    final storedCards = results[1] as List<KanbanCardModel>;
    final storedAtividades = results[2] as List<Atividade>;

    return _DashboardData(
      demandas: storedDemandas.isEmpty
          ? DemandasService.defaultDemandas()
          : storedDemandas,
      cards: storedCards.isEmpty ? KanbanService.defaultCards() : storedCards,
      atividades: storedAtividades.isEmpty
          ? AtividadesService.defaultAtividades()
          : storedAtividades,
    );
  }

  Future<void> _refresh() async {
    final next = _loadDashboardData();
    setState(() => _dashboardData = next);
    await next;
  }

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

    return FutureBuilder<_DashboardData>(
      future: _dashboardData,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: Stack(
              children: [
                const _AmbientBackground(),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      const SizedBox(height: 20),
                      if (snapshot.connectionState != ConnectionState.done)
                        const _DashboardLoading()
                      else if (snapshot.hasError)
                        _DashboardInlineError(onRetry: _refresh)
                      else
                        _OperationalOverview(
                          data: snapshot.requireData,
                          canManageDemandas:
                              AuthorizationPolicy.canManageDemandas(role),
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
            ),
          );
        },
      ),
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
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.14),
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
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
          colors: [profile.tone, profile.tone.withValues(alpha: 0.78)],
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
          Align(alignment: Alignment.topCenter, child: compactIndicators),
        ],
      ),
    );
  }

  List<_HeroInsight> _agendaInsights(
    List<CompromissoAgenda> compromissos,
    _InsightLabels labels,
  ) {
    final agora = DateTime.now();
    final doUsuario = compromissos
        .where(
          (item) =>
              item.destinatarioUserId.isEmpty ||
              item.destinatarioUserId == currentUserId,
        )
        .toList(growable: false);

    final pendentes = doUsuario
        .where((item) => item.statusConvite == StatusConviteAgenda.pendente)
        .length;

    final deHoje = doUsuario.where((item) {
      if (item.statusConvite == StatusConviteAgenda.recusado) return false;
      final inicio = DateTime.tryParse(item.inicioIso);
      if (inicio == null) return false;
      return inicio.year == agora.year &&
          inicio.month == agora.month &&
          inicio.day == agora.day;
    }).length;

    final futuros =
        doUsuario
            .where((item) {
              if (item.statusConvite == StatusConviteAgenda.recusado) {
                return false;
              }
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

    final proximo = futuros.isEmpty
        ? null
        : DateTime.tryParse(futuros.first.inicioIso);

    return [
      _HeroInsight(
        value: proximo == null ? '--' : _formatarHoraMinuto(proximo),
        label: labels.primeiro,
      ),
      _HeroInsight(value: '$pendentes', label: labels.segundo),
      _HeroInsight(value: '$deHoje', label: labels.terceiro),
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

class _DashboardData {
  const _DashboardData({
    required this.demandas,
    required this.cards,
    required this.atividades,
  });

  final List<Demanda> demandas;
  final List<KanbanCardModel> cards;
  final List<Atividade> atividades;
}

class _OperationalOverview extends StatelessWidget {
  const _OperationalOverview({
    required this.data,
    required this.canManageDemandas,
  });

  final _DashboardData data;
  final bool canManageDemandas;

  @override
  Widget build(BuildContext context) {
    final atrasadas = DashboardPrioritiesService.countDemandasAtrasadas(
      data.demandas,
    );
    final altas = DashboardPrioritiesService.countDemandasAltasAbertas(
      data.demandas,
    );
    final emAndamento = DashboardPrioritiesService.countKanbanByColumn(
      data.cards,
      'Em Progresso',
    );
    final atividadesPendentes = data.atividades
        .where(
          (item) => item.status == 'Pendente' || item.status == 'Em progresso',
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Visão operacional',
          subtitle: 'O que precisa da sua atenção neste momento',
        ),
        const SizedBox(height: 12),
        _MetricStrip(
          metrics: [
            if (canManageDemandas)
              _MetricData(
                label: 'Demandas atrasadas',
                value: '$atrasadas',
                icon: Icons.timer_off_outlined,
                tone: SigadColors.risk,
                route: AppRoutes.demandas,
              ),
            if (canManageDemandas)
              _MetricData(
                label: 'Alta prioridade',
                value: '$altas',
                icon: Icons.priority_high_rounded,
                tone: SigadColors.warning,
                route: AppRoutes.demandas,
              ),
            if (!canManageDemandas)
              _MetricData(
                label: 'Backlog urgente',
                value:
                    '${DashboardPrioritiesService.countKanbanBacklogHigh(data.cards)}',
                icon: Icons.inbox_outlined,
                tone: SigadColors.warning,
                route: AppRoutes.kanban,
              ),
            if (!canManageDemandas)
              _MetricData(
                label: 'Tarefas concluídas',
                value:
                    '${DashboardPrioritiesService.countKanbanByColumn(data.cards, 'Concluído')}',
                icon: Icons.task_alt_outlined,
                tone: SigadColors.success,
                route: AppRoutes.kanban,
              ),
            _MetricData(
              label: 'Tarefas em curso',
              value: '$emAndamento',
              icon: Icons.autorenew_rounded,
              tone: SigadColors.info,
              route: AppRoutes.kanban,
            ),
            _MetricData(
              label: 'Atividades abertas',
              value: '$atividadesPendentes',
              icon: Icons.pending_actions_outlined,
              tone: SigadColors.brand,
              route: AppRoutes.atividades,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 820;
            final attention = canManageDemandas
                ? _AttentionPanel(demandas: data.demandas)
                : _ActivitiesPanel(atividades: data.atividades);
            final flow = _FlowPanel(cards: data.cards);
            if (!wide) {
              return Column(
                children: [attention, const SizedBox(height: 14), flow],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: attention),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: flow),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    required this.route,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tone;
  final String route;
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics});

  final List<_MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 360
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 88,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).pushReplacementNamed(metric.route),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: metric.tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(metric.icon, color: metric.tone),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.value,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({required this.demandas});

  final List<Demanda> demandas;

  @override
  Widget build(BuildContext context) {
    final abertas =
        demandas.where((item) => item.statusLabel != 'Concluído').toList()
          ..sort(
            (a, b) => DemandasService.pesoPrioridade(
              a.prioridade,
            ).compareTo(DemandasService.pesoPrioridade(b.prioridade)),
          );

    return _DashboardPanel(
      title: 'Atenção agora',
      subtitle: 'Itens abertos ordenados por impacto',
      actionLabel: 'Ver todas',
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.demandas),
      child: abertas.isEmpty
          ? const _CompactEmptyState(
              icon: Icons.task_alt_rounded,
              message: 'Nenhuma demanda aberta.',
            )
          : Column(
              children: abertas
                  .take(3)
                  .map((item) => _DemandAttentionRow(demanda: item))
                  .toList(growable: false),
            ),
    );
  }
}

class _DemandAttentionRow extends StatelessWidget {
  const _DemandAttentionRow({required this.demanda});

  final Demanda demanda;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = DemandasService.tonePrioridade(demanda.prioridade);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 40,
            decoration: BoxDecoration(
              color: tone,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  demanda.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${demanda.proprietario} • prazo ${demanda.prazo}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            demanda.prioridade,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tone,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitiesPanel extends StatelessWidget {
  const _ActivitiesPanel({required this.atividades});

  final List<Atividade> atividades;

  @override
  Widget build(BuildContext context) {
    final abertas = atividades
        .where((item) => item.status != 'Concluída')
        .take(3)
        .toList(growable: false);

    return _DashboardPanel(
      title: 'Próximas atividades',
      subtitle: 'Compromissos que ainda pedem atenção',
      actionLabel: 'Ver todas',
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.atividades),
      child: abertas.isEmpty
          ? const _CompactEmptyState(
              icon: Icons.task_alt_rounded,
              message: 'Nenhuma atividade aberta.',
            )
          : Column(
              children: abertas
                  .map(
                    (atividade) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            color: AtividadesService.statusColor(
                              atividade.status,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  atividade.titulo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${atividade.responsavel} • ${atividade.data}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            atividade.status,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AtividadesService.statusColor(
                                    atividade.status,
                                  ),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _FlowPanel extends StatelessWidget {
  const _FlowPanel({required this.cards});

  final List<KanbanCardModel> cards;

  @override
  Widget build(BuildContext context) {
    final completed = DashboardPrioritiesService.countKanbanByColumn(
      cards,
      'Concluído',
    );
    final progress = cards.isEmpty ? 0.0 : completed / cards.length;
    return _DashboardPanel(
      title: 'Fluxo de tarefas',
      subtitle: '${(progress * 100).round()}% do quadro concluído',
      actionLabel: 'Abrir quadro',
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.kanban),
      child: Column(
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 14),
          ...KanbanService.colunas.map(
            (column) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      column,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${DashboardPrioritiesService.countKanbanByColumn(cards, column)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CompactEmptyState extends StatelessWidget {
  const _CompactEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 22),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(message)],
    ),
  );
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => const Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Atualizando visão operacional...'),
        ],
      ),
    ),
  );
}

class _DashboardInlineError extends StatelessWidget {
  const _DashboardInlineError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_outlined, color: SigadColors.risk),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Não foi possível atualizar os indicadores.'),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1180
            ? 4
            : constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 360
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 104,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => _ModuleCard(item: modules[index]),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.item});

  final NavigationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;
    final subtitle = item.subtitle?.trim();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: SigadColors.brand.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, color: SigadColors.brand, size: 17),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle != null && subtitle.isNotEmpty
                    ? subtitle
                    : 'Abrir módulo',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    final colors = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.surface, colors.surfaceContainerLow],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
