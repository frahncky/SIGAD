
import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../shared/widgets/status_tag.dart';

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

  static const List<_QuickAction> _quickActions = [
    _QuickAction('Nova demanda', Icons.add_circle_outline, true),
    _QuickAction('Registrar carga', Icons.edit_calendar_outlined, false),
    _QuickAction('Revisar sprint', Icons.flag_outlined, false),
    _QuickAction('Gerar relatório', Icons.picture_as_pdf_outlined, false),
  ];

  static const List<_KanbanColumn> _kanbanColumns = [
    _KanbanColumn(
      title: 'Backlog',
      tone: SigadColors.surfaceAlt,
      items: [
        _KanbanItem(
          title: 'Revisar inventário de microscópios',
          owner: 'Laboratório de Biologia',
          meta: 'Prioridade alta',
        ),
        _KanbanItem(
          title: 'Mapear demandas do semestre 2026.1',
          owner: 'Coordenação',
          meta: 'Entrega em 5 dias',
        ),
      ],
    ),
    _KanbanColumn(
      title: 'Em andamento',
      tone: SigadColors.mint,
      items: [
        _KanbanItem(
          title: 'Padronizar formulários de requisição',
          owner: 'Secretaria Acadêmica',
          meta: 'Sprint 14',
        ),
        _KanbanItem(
          title: 'Consolidar carga horária 2026.1',
          owner: 'Núcleo Docente',
          meta: '42% concluído',
        ),
      ],
    ),
    _KanbanColumn(
      title: 'Revisao',
      tone: SigadColors.accentSoft,
      items: [
        _KanbanItem(
          title: 'Auditoria de processos de estágio',
          owner: 'Comissão de Estágio',
          meta: 'Aguardando validacao',
        ),
        _KanbanItem(
          title: 'Relatório de uso dos laboratórios',
          owner: 'Gestão',
          meta: 'Revisar indicadores',
        ),
      ],
    ),
    _KanbanColumn(
      title: 'Concluido',
      tone: SigadColors.successSoft,
      items: [
        _KanbanItem(
          title: 'Planejamento das semanas de monitoria',
          owner: 'Coord. Pedagógica',
          meta: 'Finalizado ontem',
        ),
        _KanbanItem(
          title: 'Fluxo de compra de reagentes',
          owner: 'Laboratório de Química',
          meta: 'OK',
        ),
      ],
    ),
  ];

  static const List<_ActivityItem> _activities = [
    _ActivityItem(
      title: 'Laboratório de Química',
      detail: 'Atualizou demanda de reagentes',
      time: 'Hoje, 14:20',
      statusLabel: 'Em andamento',
      statusTone: SigadColors.info,
      icon: Icons.science_outlined,
    ),
    _ActivityItem(
      title: 'Prof. Ana Lemos',
      detail: 'Registrou carga horaria adicional',
      time: 'Hoje, 11:05',
      statusLabel: 'Validar',
      statusTone: SigadColors.warning,
      icon: Icons.edit_calendar_outlined,
    ),
    _ActivityItem(
      title: 'Coord. Computação',
      detail: 'Aprovou sprint 14',
      time: 'Ontem, 17:40',
      statusLabel: 'Concluido',
      statusTone: SigadColors.success,
      icon: Icons.check_circle_outline,
    ),
    _ActivityItem(
      title: 'Secretaria Acadêmica',
      detail: 'Solicitou ajustes de prazos',
      time: 'Ontem, 09:10',
      statusLabel: 'Risco',
      statusTone: SigadColors.risk,
      icon: Icons.warning_amber_outlined,
    ),
  ];

  static const List<_WorkloadItem> _workload = [
    _WorkloadItem(
      name: 'Prof. Marcos Vieira',
      hours: '32h / semana',
      meta: '2 demandas abertas',
      statusLabel: 'Em dia',
      statusTone: SigadColors.success,
    ),
    _WorkloadItem(
      name: 'Profa. Livia Santos',
      hours: '28h / semana',
      meta: '1 demanda critica',
      statusLabel: 'Alerta',
      statusTone: SigadColors.warning,
    ),
    _WorkloadItem(
      name: 'Prof. Diego Costa',
      hours: '36h / semana',
      meta: '3 demandas abertas',
      statusLabel: 'Revisar',
      statusTone: SigadColors.risk,
    ),
  ];

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
                    title: 'Kanban das demandas',
                    icon: Icons.view_kanban,
                  ),
                  const SizedBox(height: 16),
                  _KanbanPreview(
                    columns: _kanbanColumns,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 32),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ActivityFeed(items: _activities),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          child: _WorkloadPanel(items: _workload),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _ActivityFeed(items: _activities),
                        const SizedBox(height: 32),
                        _WorkloadPanel(items: _workload),
                      ],
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
                  child: _HeroText(textTheme: textTheme),
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
                _HeroText(textTheme: textTheme),
                const SizedBox(height: 16),
                _HeroControls(textTheme: textTheme),
              ],
            ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.textTheme});

  final TextTheme textTheme;

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
        const SizedBox(height: 18),
        Text(
          'Organize demandas e atividades.',
          style: textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: SigadColors.ink,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 18),
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

class _KanbanPreview extends StatelessWidget {
  const _KanbanPreview({required this.columns, required this.isWide});

  final List<_KanbanColumn> columns;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final column in columns) ...[
            Expanded(child: _KanbanColumnCard(column: column)),
            if (column != columns.last) const SizedBox(width: 16),
          ],
        ],
      );
    }

    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: columns.length,
        separatorBuilder: (_, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => SizedBox(
          width: 260,
          child: _KanbanColumnCard(column: columns[index]),
        ),
      ),
    );
  }
}

class _KanbanColumnCard extends StatelessWidget {
  const _KanbanColumnCard({required this.column});

  final _KanbanColumn column;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SigadColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: column.tone,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${column.title} (${column.items.length})',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in column.items) ...[
            _DemandCard(item: item),
            if (item != column.items.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _DemandCard extends StatelessWidget {
  const _DemandCard({required this.item});

  final _KanbanItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            item.owner,
            style: textTheme.bodySmall?.copyWith(
              color: SigadColors.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          StatusTag(label: item.meta, tone: SigadColors.brand),
        ],
      ),
    );
  }
}
class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.items});

  final List<_ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: SigadColors.brand, size: 20),
              const SizedBox(width: 8),
              Text('Atividades recentes', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            _ActivityTile(item: items[i]),
            if (i != items.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.statusTone.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: item.statusTone),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.detail,
                style: textTheme.bodySmall?.copyWith(
                  color: SigadColors.muted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    item.time,
                    style: textTheme.bodySmall?.copyWith(
                      color: SigadColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusTag(label: item.statusLabel, tone: item.statusTone),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkloadPanel extends StatelessWidget {
  const _WorkloadPanel({required this.items});

  final List<_WorkloadItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SigadColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: SigadColors.brand, size: 20),
              const SizedBox(width: 8),
              Text('Carga docente', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            _WorkloadTile(item: items[i]),
            if (i != items.length - 1) const Divider(height: 24),
          ],
        ],
      ),
    );
  }
}

class _WorkloadTile extends StatelessWidget {
  const _WorkloadTile({required this.item});

  final _WorkloadItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: SigadColors.surfaceAlt,
          child: Icon(Icons.person_outline, color: SigadColors.brand),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.hours,
                style: textTheme.bodySmall?.copyWith(
                  color: SigadColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.meta,
                style: textTheme.bodySmall?.copyWith(
                  color: SigadColors.muted,
                ),
              ),
            ],
          ),
        ),
        StatusTag(label: item.statusLabel, tone: item.statusTone),
      ],
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

class _KanbanColumn {
  const _KanbanColumn({
    required this.title,
    required this.tone,
    required this.items,
  });

  final String title;
  final Color tone;
  final List<_KanbanItem> items;
}

class _KanbanItem {
  const _KanbanItem({
    required this.title,
    required this.owner,
    required this.meta,
  });

  final String title;
  final String owner;
  final String meta;
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.detail,
    required this.time,
    required this.statusLabel,
    required this.statusTone,
    required this.icon,
  });

  final String title;
  final String detail;
  final String time;
  final String statusLabel;
  final Color statusTone;
  final IconData icon;
}

class _WorkloadItem {
  const _WorkloadItem({
    required this.name,
    required this.hours,
    required this.meta,
    required this.statusLabel,
    required this.statusTone,
  });

  final String name;
  final String hours;
  final String meta;
  final String statusLabel;
  final Color statusTone;
}
