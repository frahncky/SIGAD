import 'package:flutter/material.dart';

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
  }) : icon = Icons.hourglass_top_rounded,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final normalizedSubtitle = subtitle?.trim();
    final hasSubtitle =
        normalizedSubtitle != null && normalizedSubtitle.isNotEmpty;
    final semanticLabel = hasSubtitle
        ? '${title.trim()}. $normalizedSubtitle'
        : title.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    container: true,
                    liveRegion: true,
                    label: semanticLabel,
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              size: 36,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (showProgress) ...[
                            const SizedBox(height: 14),
                            const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: 6),
                            Text(
                              normalizedSubtitle,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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

        if (!constraints.hasBoundedHeight) {
          return content;
        }

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}
