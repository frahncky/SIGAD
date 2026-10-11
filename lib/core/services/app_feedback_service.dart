import 'package:flutter/material.dart';

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
          closeIconColor: colors.foreground,
          showCloseIcon: true,
          content: Semantics(
            container: true,
            liveRegion: true,
            label: '${kind.label}: $message',
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(kind.icon, color: colors.foreground, size: 22),
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
      );
  }
}

enum _FeedbackKind {
  info(label: 'Informação', icon: Icons.info_outline_rounded),
  success(label: 'Sucesso', icon: Icons.check_circle_outline_rounded),
  warning(label: 'Atenção', icon: Icons.warning_amber_rounded),
  error(label: 'Erro', icon: Icons.error_outline_rounded);

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
