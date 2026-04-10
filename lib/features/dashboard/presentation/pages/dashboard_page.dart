
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
    ),
    _Metric(
      label: 'Em andamento',
      value: '12',
      detail: '4 com risco de atraso',
      icon: Icons.play_circle_outline,
      tone: SigadColors.info,
    ),
    _Metric(
      label: 'Docentes ativos',
      value: '38',
      detail: '94% com carga registrada',
      icon: Icons.school_outlined,
      tone: SigadColors.success,
    ),
    _Metric(
      label: 'SLA medio',
      value: '3,4 dias',
      detail: 'Meta: 4 dias',
      icon: Icons.timer_outlined,
      tone: SigadColors.accent,
    ),
  ];

  static const List<_QuickAction> _quickActions = [
    _QuickAction('Nova demanda', Icons.add_circle_outline, true),
    _QuickAction('Registrar carga', Icons.edit_calendar_outlined, false),
    _QuickAction('Revisar sprint', Icons.flag_outlined, false),
    _QuickAction('Gerar relatorio', Icons.picture_as_pdf_outlined, false),
  ];

  static const List<_KanbanColumn> _kanbanColumns = [
    _KanbanColumn(
      title: 'Backlog',
      tone: SigadColors.surfaceAlt,
      items: [
        _KanbanItem(
          title: 'Revisar inventario de microscopios',
          owner: 'Laboratorio de Biologia',
          meta: 'Prioridade alta',
        ),
        _KanbanItem(
          title: 'Mapear demandas do semestre 2026.1',
          owner: 'Coordenacao',
          meta: 'Entrega em 5 dias',
        ),
      ],
    ),
    _KanbanColumn(
      title: 'Em andamento',
      tone: SigadColors.mint,
      items: [
        _KanbanItem(
          title: 'Padronizar formularios de requisicao',
          owner: 'Secretaria Academica',
          meta: 'Sprint 14',
        ),
        _KanbanItem(
          title: 'Consolidar carga horaria 2026.1',
          owner: 'Nucleo Docente',
          meta: '42% concluido',
        ),
      ],
    ),
    _KanbanColumn(
      title: 'Revisao',
      tone: SigadColors.accentSoft,
      items: [
        _KanbanItem(
          title: 'Auditoria de processos de estagio',
          owner: 'Comissao de estagio',
          meta: 'Aguardando validacao',
        ),
        _KanbanItem(
          title: 'Relatorio de uso dos laboratorios',
          owner: 'Gestao',
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
          owner: 'Coord. Pedagogica',
          meta: 'Finalizado ontem',
        ),
        _KanbanItem(
          title: 'Fluxo de compra de reagentes',
          owner: 'Laboratorio de Quimica',
          meta: 'OK',
        ),
      ],
    ),
  ];

  static const List<_ActivityItem> _activities = [
    _ActivityItem(
      title: 'Laboratorio de Quimica',
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
      title: 'Coord. Computacao',
      detail: 'Aprovou sprint 14',
      time: 'Ontem, 17:40',
      statusLabel: 'Concluido',
      statusTone: SigadColors.success,
      icon: Icons.check_circle_outline,
    ),
    _ActivityItem(
      title: 'Secretaria Academica',
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
                  const SizedBox(height: 24),
                  const _SectionHeader(
                    title: 'Resumo da semana',
                    actionLabel: 'Ver detalhes',
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(metrics: _metrics),
                  const SizedBox(height: 24),
                  const _SectionHeader(
                    title: 'Acoes rapidas',
                    actionLabel: 'Personalizar',
                  ),
                  const SizedBox(height: 12),
                  _QuickActions(actions: _quickActions),
                  const SizedBox(height: 24),
                  const _SectionHeader(
                    title: 'Kanban das demandas',
                    actionLabel: 'Abrir quadro',
                  ),
                  const SizedBox(height: 12),
                  _KanbanPreview(
                    columns: _kanbanColumns,
                    isWide: isWide,
                  ),
                  const SizedBox(height: 24),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ActivityFeed(items: _activities),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _WorkloadPanel(items: _workload),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _ActivityFeed(items: _activities),
                        const SizedBox(height: 24),
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sistema Integrado de Gestao Academica de Demandas',
          style: textTheme.titleMedium?.copyWith(
            color: SigadColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Planeje, distribua e acompanhe demandas, carga docente e atividades\nacademicas em um unico fluxo de trabalho.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: const [
            _InfoChip(label: 'Sprint 14'),
            _InfoChip(label: 'Semestre 2026.1'),
            _InfoChip(label: '17 laboratorios ativos'),
          ],
        ),
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
          'Busca rapida',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            hintText: 'Demandas, docentes, laboratorios...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SigadColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.track_changes_outlined, color: SigadColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta institucional',
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reduzir SLA medio para 3 dias ate junho.',
                      style: textTheme.bodySmall?.copyWith(
                        color: SigadColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusTag(
                label: 'Em andamento',
                tone: SigadColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: SigadColors.ink,
            ),
      ),
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
                  style: textTheme.labelLarge?.copyWith(
                    color: SigadColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  metric.value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  metric.detail,
                  style: textTheme.bodySmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                ? FilledButton.icon(
                    onPressed: () {},
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  )
                : OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(action.icon, color: SigadColors.brand),
                    label: Text(action.label),
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
                column.title,
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
          Text('Atividades recentes', style: textTheme.titleMedium),
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
          Text('Carga docente', style: textTheme.titleMedium),
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
  const _SectionHeader({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            child: Text(actionLabel!),
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
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color tone;
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
