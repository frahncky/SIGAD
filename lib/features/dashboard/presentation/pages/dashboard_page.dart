
import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<_Metric> _metrics = [
    _Metric(
      label: 'Demandas abertas',
      value: '24',
      detail: '+6 nesta semana',
      icon: Icons.inbox_outlined,
      tone: SigadColors.brand,
      trend: Icons.trending_up,
    ),
    _Metric(
      label: 'Em andamento',
      value: '12',
      detail: '4 com risco de atraso',
      icon: Icons.play_circle_outline,
      tone: SigadColors.info,
      trend: Icons.trending_down,
    ),
    _Metric(
      label: 'Docentes ativos',
      value: '38',
      detail: '94% com carga registrada',
      icon: Icons.school_outlined,
      tone: SigadColors.success,
      trend: Icons.trending_up,
    ),
    _Metric(
      label: 'SLA médio',
      value: '3,4 dias',
      detail: 'Meta: 4 dias',
      icon: Icons.timer_outlined,
      tone: SigadColors.accent,
      trend: Icons.trending_up,
    ),
  ];

  static const List<_HeroStat> _heroStats = [
    _HeroStat(label: 'Urgentes', value: '4', tone: SigadColors.risk),
    _HeroStat(label: 'Em andamento', value: '12', tone: SigadColors.info),
    _HeroStat(label: 'SLA', value: '3,4d', tone: SigadColors.accent),
  ];

  static const List<_QuickAction> _quickActions = [
    _QuickAction('Nova demanda', Icons.add_circle_outline, true),
    _QuickAction('Registrar carga', Icons.edit_calendar_outlined, false),
    _QuickAction('Revisar sprint', Icons.flag_outlined, false),
    _QuickAction('Gerar relatório', Icons.picture_as_pdf_outlined, false),
  ];

  static const _UrgentSummary _urgentSummary = _UrgentSummary(
    title: 'Atenção imediata',
    detail: '4 demandas com risco de atraso',
    subtext: 'Priorize revisões, aprovações e realocações.',
    icon: Icons.warning_amber_outlined,
    tone: SigadColors.risk,
    actionLabel: 'Ver urgentes',
  );

  List<Widget> _buildAccessCards() {
    return [
      _AccessCard(
        icon: Icons.view_kanban,
        label: 'Kanban',
        description: 'Gerenciar demandas',
        route: '/kanban',
      ),
      _AccessCard(
        icon: Icons.history,
        label: 'Atividades',
        description: 'Registro de entregas',
        route: '/atividades',
      ),
      _AccessCard(
        icon: Icons.schedule,
        label: 'Carga docente',
        description: 'Distribuição de carga',
        route: '/carga-docente',
      ),
      _AccessCard(
        icon: Icons.assignment,
        label: 'Demandas',
        description: 'Ver todas as demandas',
        route: '/demandas',
      ),
      _AccessCard(
        icon: Icons.insights,
        label: 'Relatórios',
        description: 'Gerar relatórios',
        route: '/relatorios',
      ),
      _AccessCard(
        icon: Icons.settings,
        label: 'Configurações',
        description: 'Ajustes do sistema',
        route: '/configuracoes',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        return Stack(
          children: [
            const _AmbientBackground(),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 20,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroHeader(isWide: isWide),
                  const SizedBox(height: 32),
                  const _SectionHeader(
                    title: 'Resumo da semana',
                    icon: Icons.bar_chart,
                  ),
                  const SizedBox(height: 16),
                  _MetricsGrid(metrics: _metrics),
                  const SizedBox(height: 32),
                  const _SectionHeader(
                    title: 'Ações rápidas',
                    icon: Icons.flash_on,
                  ),
                  const SizedBox(height: 16),
                  _QuickActions(actions: _quickActions),
                  const SizedBox(height: 32),
                  const _SectionHeader(
                    title: 'Acessos principais',
                    icon: Icons.apps,
                  ),
                  const SizedBox(height: 16),
                  if (isWide)
                    GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _buildAccessCards(),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _buildAccessCards(),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SigadColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HeroText(
                    textTheme: textTheme,
                    summary: DashboardPage._urgentSummary,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _HeroControls(textTheme: textTheme),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroText(
                  textTheme: textTheme,
                  summary: DashboardPage._urgentSummary,
                ),
                const SizedBox(height: 16),
                _HeroControls(textTheme: textTheme),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.textTheme, required this.summary});

  final TextTheme textTheme;
  final _UrgentSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Painel SIGAD',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sistema Integrado de Gestão Acadêmica de Demandas',
          style: textTheme.titleMedium?.copyWith(
            color: SigadColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: DashboardPage._heroStats
              .map(
                (stat) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: stat.tone.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: stat.tone.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stat.value,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: stat.tone,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stat.label,
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        _UrgentAlert(summary: summary),
      ],
    );
  }
}
class _HeroControls extends StatelessWidget {
  const _HeroControls({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Busca rápida',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Buscar demandas, docentes, laboratórios...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: SigadColors.surfaceAlt,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisExtent: 130,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
        boxShadow: [
          BoxShadow(
            color: metric.tone.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: metric.tone.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(metric.icon, color: metric.tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: SigadColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  metric.value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (metric.trend != null)
                      Icon(
                        metric.trend,
                        size: 14,
                        color: metric.tone,
                      ),
                    if (metric.trend != null) const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        metric.detail,
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (action) => action.primary
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: SigadColors.brand.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: Icon(action.icon),
                      label: Text(action.label),
                      style: FilledButton.styleFrom(
                        backgroundColor: SigadColors.brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(action.icon, color: SigadColors.brand),
                      label: Text(action.label),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: SigadColors.divider),
                        foregroundColor: SigadColors.brand,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
          )
          .toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: SigadColors.brand, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UrgentSummary {
  const _UrgentSummary({
    required this.title,
    required this.detail,
    required this.subtext,
    required this.icon,
    required this.tone,
    required this.actionLabel,
  });

  final String title;
  final String detail;
  final String subtext;
  final IconData icon;
  final Color tone;
  final String actionLabel;
}

class _HeroStat {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;
}

class _UrgentAlert extends StatelessWidget {
  const _UrgentAlert({required this.summary});

  final _UrgentSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: summary.tone.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: summary.tone.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: summary.tone.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: summary.tone.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: summary.tone.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(summary.icon, color: summary.tone, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SigadColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.detail,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: summary.tone,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.subtext,
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(summary.actionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: summary.tone,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
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
                  colors: [
                    SigadColors.canvas,
                    SigadColors.surfaceAlt,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -120,
            top: -40,
            child: _GlowOrb(color: SigadColors.accentSoft, size: 260),
          ),
          Positioned(
            left: -80,
            bottom: -60,
            child: _GlowOrb(color: SigadColors.mint, size: 220),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.45),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.tone,
    this.trend,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color tone;
  final IconData? trend;
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.primary);

  final String label;
  final IconData icon;
  final bool primary;
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String description;
  final String route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: SigadColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SigadColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).pushNamed(route);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: SigadColors.brand.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: SigadColors.brand,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
