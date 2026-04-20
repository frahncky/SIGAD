import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';

class PageStatusView extends StatelessWidget {
  const PageStatusView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  const PageStatusView.loading({
    super.key,
    this.title = 'Carregando dados...',
    this.subtitle,
  })  : icon = Icons.hourglass_top_rounded,
        actionLabel = null,
        onAction = null,
        showProgress = true;

  const PageStatusView.empty({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title = 'Nenhum registro encontrado',
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : showProgress = false;

  const PageStatusView.error({
    super.key,
    this.icon = Icons.error_outline,
    this.title = 'Não foi possível carregar os dados',
    this.subtitle,
    this.actionLabel = 'Tentar novamente',
    this.onAction,
  }) : showProgress = false;

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: SigadColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 36, color: SigadColors.muted),
              ),
              if (showProgress) ...[
                const SizedBox(height: 14),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.refresh),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
