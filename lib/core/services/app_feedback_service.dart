import 'package:flutter/material.dart';
import 'package:sigad/app/theme/sigad_icon.dart';
import 'package:sigad/app/theme/sigad_icons.dart';

abstract final class AppFeedbackService {
  static void info(BuildContext context, String message) {
    _show(context, message, kind: _FeedbackKind.info);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, kind: _FeedbackKind.success);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, kind: _FeedbackKind.warning);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, kind: _FeedbackKind.error);
  }

  static void _show(
    BuildContext context,
    String message, {
    required _FeedbackKind kind,
  }) {
    final theme = Theme.of(context);
    final colors = kind.colors(theme.colorScheme);
    final contentTextStyle =
        (theme.snackBarTheme.contentTextStyle ??
                theme.textTheme.bodyMedium ??
                DefaultTextStyle.of(context).style)
            .copyWith(color: colors.foreground);
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colors.background,
          // O botão de fechar é próprio para usar o ícone do SIGAD; o
          // `showCloseIcon` do SnackBar usa sempre o ícone Material.
          padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    label: '${kind.label}: $message',
                    child: ExcludeSemantics(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SigadIcon(
                            kind.icon,
                            color: colors.foreground,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kind.label,
                                  style: contentTextStyle.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(message, style: contentTextStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const SigadIcon(SigadIcons.fechar),
                color: colors.foreground,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => messenger.hideCurrentSnackBar(
                  reason: SnackBarClosedReason.dismiss,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

enum _FeedbackKind {
  info(label: 'Informação', icon: SigadIcons.info),
  success(label: 'Sucesso', icon: SigadIcons.concluido),
  warning(label: 'Atenção', icon: SigadIcons.alerta),
  error(label: 'Erro', icon: SigadIcons.erro);

  const _FeedbackKind({required this.label, required this.icon});

  final String label;
  final IconData icon;

  ({Color background, Color foreground}) colors(ColorScheme scheme) {
    return switch (this) {
      _FeedbackKind.info => (
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
      _FeedbackKind.success => (
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      _FeedbackKind.warning => (
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      _FeedbackKind.error => (
        background: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
      ),
    };
  }
}
