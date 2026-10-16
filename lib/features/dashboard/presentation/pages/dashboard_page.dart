import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
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
import '../../../mural/presentation/mural_visual.dart';
import '../../../mural/presentation/state/mural_controller.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../../../shared/widgets/welcome_hero.dart';
import '../../../../l10n/l10n.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.agora});

  final DateTime? agora;

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
    final mural = _maybeMural(context);
    final avisos = mural?.avisosVisiveis(role) ?? const [];

    return FutureBuilder<_DashboardData>(
      future: _dashboardData,
      builder: (context, snapshot) => LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1024;
          final canManageDemandas = AuthorizationPolicy.canManageDemandas(role);
          final alerts = _buildDashboardAlerts(
            l10n: context.l10n,
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
                      WelcomeHero(
                        agora: widget.agora,
                        avisos: [
                          for (final aviso in avisos)
                            WelcomeHeroItem(
                              icon: aviso.modelo.icone,
                              title: aviso.titulo,
                              subtitle: aviso.conteudo,
                              color: aviso.modelo.cor,
                            ),
                        ],
                        frase: mural?.fraseAtual?.texto,
                        resumo: [
                          for (final alert in alerts)
                            WelcomeHeroItem(
                              icon: alert.icon,
                              title: alert.title,
                              subtitle: alert.subtitle,
                              color: alert.tone,
                            ),
                        ],
                      ),
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
  required AppLocalizations l10n,
  required bool canManageDemandas,
  required bool hasError,
}) {
  final fallback = hasError
      ? l10n.dadosIndisponiveis
      : l10n.atualizandoInformacoes;
  final atividades = data == null
      ? fallback
      : l10n.atividadesRegistradas(data.atividades.length);
  final cards = data == null ? fallback : l10n.itensFluxo(data.cards.length);
  final demandas = data == null
      ? fallback
      : l10n.demandasRegistradas(data.demandas.length);

  return [
    DashboardAlertItem(
      icon: SigadIcons.eventoNota,
      title: l10n.atividadesDepartamento,
      subtitle: atividades,
      tone: SigadColors.success,
    ),
    DashboardAlertItem(
      icon: SigadIcons.kanban,
      title: l10n.quadroTrabalho,
      subtitle: cards,
      tone: SigadColors.info,
    ),
    if (canManageDemandas)
      DashboardAlertItem(
        icon: SigadIcons.demanda,
        title: l10n.demandasDepartamento,
        subtitle: demandas,
        tone: SigadColors.warning,
      )
    else
      DashboardAlertItem(
        icon: SigadIcons.escudo,
        title: l10n.acessoDepartamento,
        subtitle: l10n.acessoDepartamentoSub,
        tone: SigadColors.info,
      ),
  ];
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
      title: context.l10n.atencaoAgora,
      subtitle: context.l10n.atencaoAgoraSub,
      actionLabel: context.l10n.verTodas,
      icon: SigadIcons.prioridade,
      tone: SigadColors.risk,
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.demandas),
      child: abertas.isEmpty
          ? _CompactEmptyState(
              icon: SigadIcons.concluido,
              message: context.l10n.nenhumaDemandaAberta,
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
                  context.l10n.responsavelPrazo(
                    demanda.proprietario,
                    demanda.prazo,
                  ),
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
      title: context.l10n.proximasAtividades,
      subtitle: context.l10n.proximasAtividadesSub,
      actionLabel: context.l10n.verTodas,
      icon: SigadIcons.eventoNota,
      tone: SigadColors.info,
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.atividades),
      child: abertas.isEmpty
          ? _CompactEmptyState(
              icon: SigadIcons.concluido,
              message: context.l10n.nenhumaAtividadeAberta,
            )
          : Column(
              children: abertas
                  .map(
                    (atividade) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SigadIcon(
                            SigadIcons.eventoNota,
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
                Flexible(
                  child: TextButton(
                    onPressed: onAction,
                    child: Text(actionLabel, textAlign: TextAlign.end),
                  ),
                ),
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
      children: [
        SigadIcon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(child: Text(message)),
      ],
    ),
  );
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) => Card(
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
          Flexible(child: Text(context.l10n.atualizandoVisao)),
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
          const SigadIcon(
            SigadIcons.sincronizacaoErro,
            color: SigadColors.risk,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.erroIndicadores)),
          TextButton.icon(
            onPressed: onRetry,
            icon: const SigadIcon(SigadIcons.atualizar),
            label: Text(context.l10n.tentarNovamente),
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
                  context.l10n.acessoRapido,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.escolhaAtalhos,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                for (final item in _todosAtalhos)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _visiveis.contains(item.route),
                    title: Text(item.rotuloEm(context.l10n)),
                    secondary: SigadIcon(item.icon, color: SigadColors.brand),
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
            const SigadIcon(
              SigadIcons.raio,
              color: SigadColors.brand,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.acessoRapido,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: _abrirSeletorDeAtalhos,
              tooltip: context.l10n.personalizarAtalhos,
              icon: const SigadIcon(SigadIcons.painelPersonalizar),
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
                SigadIcon(
                  SigadIcons.painelPersonalizar,
                  size: 26,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.nenhumAtalho,
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
              final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
              final colunas = constraints.maxWidth >= 640
                  ? 4
                  : constraints.maxWidth >= 320 && !largeText
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
      constraints: const BoxConstraints(minHeight: 96),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SigadIcon(item.icon, color: SigadColors.brand, size: 24),
                const SizedBox(height: 8),
                Text(
                  item.rotuloEm(context.l10n),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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

MuralController? _maybeMural(BuildContext context) {
  try {
    return Provider.of<MuralController>(context);
  } on ProviderNotFoundException {
    return null;
  }
}
