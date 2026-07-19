import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../core/config/institutional_context.dart';
import '../../../../core/models/navigation_item.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../atividades/data/atividade_repository.dart';
import '../../../atividades/domain/atividade_models.dart';
import '../../../atividades/domain/atividades_service.dart';
import '../../../demandas/data/demanda_repository.dart';
import '../../../demandas/domain/demanda_models.dart';
import '../../../demandas/domain/demandas_service.dart';
import '../../../kanban/data/kanban_repository.dart';
import '../../../kanban/domain/kanban_models.dart';
import '../../../../shared/widgets/icon_avatar.dart';

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
      demandas: storedDemandas,
      cards: storedCards,
      atividades: storedAtividades,
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

    return FutureBuilder<_DashboardData>(
      future: _dashboardData,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          final canManageDemandas = AuthorizationPolicy.canManageDemandas(role);
          final alerts = _buildDashboardAlerts(
            snapshot.data,
            canManageDemandas: canManageDemandas,
            hasError: snapshot.hasError,
          );
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
                      DashboardAlertsCard(alerts: alerts),
                      const SizedBox(height: 20),
                      _CustomizableIndicators(role: role),
                      const SizedBox(height: 20),
                      if (snapshot.connectionState != ConnectionState.done)
                        const _DashboardLoading()
                      else if (snapshot.hasError)
                        _DashboardInlineError(onRetry: _refresh)
                      else if (canManageDemandas)
                        _AttentionPanel(demandas: snapshot.requireData.demandas)
                      else
                        _ActivitiesPanel(
                          atividades: snapshot.requireData.atividades,
                        ),
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

List<DashboardAlertItem> _buildDashboardAlerts(
  _DashboardData? data, {
  required bool canManageDemandas,
  required bool hasError,
}) {
  final fallback = hasError
      ? 'Dados indisponíveis. Puxe para atualizar.'
      : 'Atualizando informações';
  final atividades = data == null
      ? fallback
      : data.atividades.length == 1
      ? '1 atividade registrada'
      : '${data.atividades.length} atividades registradas';
  final cards = data == null
      ? fallback
      : data.cards.length == 1
      ? '1 item no fluxo de trabalho'
      : '${data.cards.length} itens no fluxo de trabalho';
  final demandas = data == null
      ? fallback
      : data.demandas.length == 1
      ? '1 demanda registrada'
      : '${data.demandas.length} demandas registradas';

  return [
    DashboardAlertItem(
      icon: Icons.event_note_outlined,
      title: 'Atividades do departamento',
      subtitle: atividades,
      tone: SigadColors.success,
    ),
    DashboardAlertItem(
      icon: Icons.view_kanban_outlined,
      title: 'Quadro de trabalho',
      subtitle: cards,
      tone: SigadColors.info,
    ),
    if (canManageDemandas)
      DashboardAlertItem(
        icon: Icons.assignment_outlined,
        title: 'Demandas do departamento',
        subtitle: demandas,
        tone: SigadColors.warning,
      )
    else
      const DashboardAlertItem(
        icon: Icons.admin_panel_settings_outlined,
        title: 'Acesso ao departamento',
        subtitle: 'Informações exibidas conforme seu perfil',
        tone: SigadColors.info,
      ),
  ];
}

/// Resumo compacto das informações prioritárias do departamento.
class DashboardAlertsCard extends StatelessWidget {
  const DashboardAlertsCard({super.key, required this.alerts});

  final List<DashboardAlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dashboard-alerts-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SigadColors.brand, SigadColors.brandDark],
        ),
        boxShadow: [
          BoxShadow(
            color: SigadColors.brand.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < alerts.length; index++) ...[
            _AlertRow(alert: alerts[index]),
            if (index < alerts.length - 1)
              Divider(
                height: 1,
                indent: 44,
                color: Colors.white.withValues(alpha: 0.16),
              ),
          ],
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.22)),
          _DepartmentFooter(alerts: alerts),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});

  final DashboardAlertItem alert;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '${alert.title}. ${alert.subtitle}',
      onTap: () => _showAlertDialog(context, alert),
      child: Material(
        key: ValueKey('dashboard-alert-${alert.title}'),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAlertDialog(context, alert),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Row(
                children: [
                  _AlertIcon(icon: alert.icon, tone: alert.tone),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon({required this.icon, required this.tone});

  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: tone.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, size: 23, color: Colors.white),
  );
}

class _DepartmentFooter extends StatelessWidget {
  const _DepartmentFooter({required this.alerts});

  final List<DashboardAlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final stackActions =
        mediaQuery.size.width < 350 || mediaQuery.textScaler.scale(1) > 1.3;
    final department = Row(
      children: [
        const _AlertIcon(
          icon: Icons.business_outlined,
          tone: SigadColors.success,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                InstitutionalContext.department,
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${InstitutionalContext.acronym} ${InstitutionalContext.campus}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 11.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    final action = Semantics(
      button: true,
      onTap: () => _showAllAlertsDialog(context, alerts),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.34)),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () => _showAllAlertsDialog(context, alerts),
        child: const Text('Ver tudo', style: TextStyle(fontSize: 12.5)),
      ),
    );

    return Padding(
      key: const Key('dashboard-alerts-footer'),
      padding: const EdgeInsets.only(top: 6),
      child: stackActions
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 58),
                  child: department,
                ),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 58),
                    child: department,
                  ),
                ),
                const SizedBox(width: 8),
                action,
              ],
            ),
    );
  }
}

class DashboardAlertItem {
  const DashboardAlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tone;
}

Future<void> _showAlertDialog(BuildContext context, DashboardAlertItem alert) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(alert.title),
        content: Text(alert.subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

Future<void> _showAllAlertsDialog(
  BuildContext context,
  List<DashboardAlertItem> alerts,
) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    scrollable: true,
    title: const Text('Avisos do departamento'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < alerts.length; index++) ...[
          Text(
            alerts[index].title,
            style: Theme.of(
              dialogContext,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(alerts[index].subtitle),
          if (index < alerts.length - 1) const Divider(height: 24),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(dialogContext).pop(),
        child: const Text('Fechar'),
      ),
    ],
  ),
);

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
      icon: Icons.priority_high_rounded,
      tone: SigadColors.risk,
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
      icon: Icons.event_note_outlined,
      tone: SigadColors.info,
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

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    required this.child,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;
  final IconData icon;
  final Color tone;

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
        side: BorderSide(color: tone.withValues(alpha: 0.16)),
      ),
      shadowColor: tone.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SigadIconAvatar(icon: icon, tone: tone),
                const SizedBox(width: 12),
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

/// Atalhos compactos e personalizáveis para os itens mais importantes do
/// menu lateral: o usuário escolhe, pelo ícone de ajuste, quais aparecem
/// na Visão geral.
class _CustomizableIndicators extends StatefulWidget {
  const _CustomizableIndicators({required this.role});

  final UserRole? role;

  @override
  State<_CustomizableIndicators> createState() =>
      _CustomizableIndicatorsState();
}

class _CustomizableIndicatorsState extends State<_CustomizableIndicators> {
  static const _prefsKey = 'sigad_dashboard_atalhos_visiveis';

  late Set<String> _visiveis;

  List<NavigationItem> get _todosAtalhos => kNavigationItems
      .where((item) => item.route != AppRoutes.dashboard)
      .where((item) => widget.role == null || item.isAvailableFor(widget.role!))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _visiveis = _todosAtalhos.map((item) => item.route).toSet();
    _carregarPreferencia();
  }

  Future<void> _carregarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList(_prefsKey);
    if (salvos != null && mounted) {
      final disponiveis = _todosAtalhos.map((item) => item.route).toSet();
      setState(() => _visiveis = salvos.toSet().intersection(disponiveis));
    }
  }

  Future<void> _salvarPreferencia() {
    return SharedPreferences.getInstance().then(
      (prefs) => prefs.setStringList(_prefsKey, _visiveis.toList()),
    );
  }

  void _abrirSeletorDeAtalhos() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  'Acesso rápido',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escolha quais atalhos do menu aparecem na visão geral.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                for (final item in _todosAtalhos)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _visiveis.contains(item.route),
                    title: Text(item.label),
                    secondary: Icon(item.icon, color: SigadColors.brand),
                    onChanged: (selecionado) {
                      setModalState(() {
                        if (selecionado ?? false) {
                          _visiveis.add(item.route);
                        } else {
                          _visiveis.remove(item.route);
                        }
                      });
                      setState(() {});
                      _salvarPreferencia();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final atalhosVisiveis = _todosAtalhos
        .where((item) => _visiveis.contains(item.route))
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_outlined, color: SigadColors.brand, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Acesso rápido',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: _abrirSeletorDeAtalhos,
              tooltip: 'Personalizar atalhos',
              icon: const Icon(Icons.dashboard_customize_outlined),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (atalhosVisiveis.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: 26,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Nenhum atalho selecionado. Toque no ícone acima para escolher.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final colunas = constraints.maxWidth >= 640
                  ? 4
                  : constraints.maxWidth >= 420
                  ? 3
                  : 2;
              final largura =
                  ((constraints.maxWidth - ((colunas - 1) * 10)) / colunas)
                      .clamp(0.0, double.infinity);
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final item in atalhosVisiveis)
                    SizedBox(
                      width: largura,
                      child: _AtalhoCard(item: item),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _AtalhoCard extends StatelessWidget {
  const _AtalhoCard({required this.item});

  final NavigationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Icon(item.icon, color: SigadColors.brand, size: 24),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
