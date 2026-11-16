import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';
import '../../app/theme/sigad_icon.dart';
import '../../app/theme/sigad_icons.dart';

/// Componentes visuais compartilhados por Demandas, Tarefas e Atividades,
/// alinhados ao padrão da Visão geral (cards raio 16, painéis raio 22,
/// borda `outlineVariant`, sombra leve e cores do `ColorScheme`).

bool _escuro(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

/// Ajusta um tom da paleta para texto legível no tema claro e no escuro.
Color tomLegivel(BuildContext context, Color tom) {
  return _escuro(context)
      ? Color.lerp(tom, Colors.white, 0.45)!
      : Color.lerp(tom, Colors.black, 0.26)!;
}

/// Cor de risco para texto e ícones (atrasado, vence hoje).
Color corRisco(BuildContext context) => _escuro(context)
    ? Color.lerp(SigadColors.risk, Colors.white, 0.45)!
    : SigadColors.risk;

/// Card com superfície, borda e feedback de toque padronizados.
class SigadSurfaceCard extends StatelessWidget {
  const SigadSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borda = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: borda,
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: borda,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Selo tonal de prioridade com contraste AA.
///
/// [prioridade] é o valor gravado (`Alta`, `Média`, `Baixa`); [label] é o
/// texto exibido no idioma atual.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.prioridade,
    required this.label,
    this.semanticLabel,
  });

  /// Texto da prioridade alta sobre `riskSoft` (5,5:1). O `risk` puro fica
  /// em 4,4:1, abaixo do mínimo AA para texto pequeno.
  static const corTextoAlta = Color(0xFF9F3636);

  /// Fundo e texto da prioridade média (7:1).
  static const fundoMedia = Color(0xFFFFEAD7);
  static const corTextoMedia = Color(0xFF7A3E0E);

  final String prioridade;
  final String label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final escuro = _escuro(context);
    final (Color fundo, Color texto, IconData? icone) = switch (prioridade) {
      'Alta' => (
        escuro
            ? SigadColors.risk.withValues(alpha: 0.32)
            : SigadColors.riskSoft,
        escuro
            ? Color.lerp(SigadColors.risk, Colors.white, 0.6)!
            : corTextoAlta,
        SigadIcons.prioridade,
      ),
      'Média' => (
        escuro ? SigadColors.warning.withValues(alpha: 0.32) : fundoMedia,
        escuro
            ? Color.lerp(SigadColors.warning, Colors.white, 0.6)!
            : corTextoMedia,
        null,
      ),
      _ => (colors.surfaceContainerHighest, colors.onSurfaceVariant, null),
    };
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              SigadIcon(icone, size: 14, color: texto, accentColor: texto),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: texto,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selo tonal com ícone e texto (status).
class ToneChip extends StatelessWidget {
  const ToneChip({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final Color tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final texto = tomLegivel(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: _escuro(context) ? 0.28 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SigadIcon(icon, size: 14, color: texto, accentColor: texto),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: texto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadado com ícone e texto. Com [risco], usa a cor de risco e negrito;
/// o ícone e o texto sempre acompanham a cor, nunca só a cor.
class MetaLabel extends StatelessWidget {
  const MetaLabel({
    super.key,
    required this.icon,
    required this.text,
    this.risco = false,
    this.semanticLabel,
  });

  final IconData icon;
  final String text;
  final bool risco;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cor = risco
        ? corRisco(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SigadIcon(
            icon,
            size: 16,
            color: cor,
            accentColor: risco ? cor : null,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cor,
                fontWeight: risco ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador do painel de resumo.
class SummaryKpi {
  const SummaryKpi({
    required this.label,
    required this.value,
    this.tone,
    this.risco = false,
  });

  final String label;
  final int value;
  final Color? tone;

  /// Destaca o indicador com cor de risco e ícone de alerta.
  final bool risco;
}

/// Painel de indicadores que vira lista vertical em telas estreitas ou com
/// fonte ampliada, para que os rótulos nunca sejam cortados.
class SummaryKpiPanel extends StatelessWidget {
  const SummaryKpiPanel({super.key, required this.items});

  final List<SummaryKpi> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final vertical = constraints.maxWidth < 330 || textScale > 1.3;
          if (vertical) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _KpiTile(item: items[i], horizontal: true),
                ],
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _KpiTile(item: items[i], horizontal: false)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.item, required this.horizontal});

  final SummaryKpi item;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final risco = item.risco;
    final corValor = risco
        ? corRisco(context)
        : item.tone == null
        ? colors.onSurface
        : tomLegivel(context, item.tone!);
    final fundo = risco
        ? SigadColors.risk.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.24 : 0.10,
          )
        : colors.surfaceContainer;
    final rotulo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (risco) ...[
          SigadIcon(
            SigadIcons.alerta,
            size: 16,
            color: corValor,
            accentColor: corValor,
          ),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            item.label,
            maxLines: horizontal ? null : 2,
            style: theme.textTheme.bodySmall?.copyWith(
              color: risco ? corValor : colors.onSurfaceVariant,
              fontWeight: risco ? FontWeight.w700 : null,
            ),
          ),
        ),
      ],
    );
    final valor = Text(
      '${item.value}',
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: corValor,
      ),
    );
    return Semantics(
      container: true,
      label: '${item.value} ${item.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(14),
        ),
        child: horizontal
            ? Row(
                children: [
                  Expanded(child: rotulo),
                  const SizedBox(width: 12),
                  valor,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [rotulo, const SizedBox(height: 4), valor],
              ),
      ),
    );
  }
}

/// Estado vazio compacto com ícone em círculo suave.
class SoftEmptyState extends StatelessWidget {
  const SoftEmptyState({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: text,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: SigadIcon(icon, size: 26, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão quadrado de filtro (48dp) com selo do número de filtros ativos.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.tooltip,
    required this.activeCount,
    required this.onPressed,
  });

  final String tooltip;
  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Badge(
        isLabelVisible: activeCount > 0,
        label: Text('$activeCount'),
        child: SizedBox(
          width: 48,
          height: 48,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 48),
            ),
            child: const SigadIcon(SigadIcons.filtro),
          ),
        ),
      ),
    );
  }
}

/// Título de seção de um sheet de filtros.
class SheetSectionTitle extends StatelessWidget {
  const SheetSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Linha de detalhe (rótulo acima, valor abaixo) sem truncamento.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
