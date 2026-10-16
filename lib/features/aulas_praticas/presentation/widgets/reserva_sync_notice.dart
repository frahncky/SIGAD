import 'package:flutter/material.dart';

import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';

/// Aviso persistente da agenda, inclusive quando o SnackBar desaparece.
/// O botão permite recarregar sem repetir automaticamente um PUT incerto.
class ReservaSyncNotice extends StatelessWidget {
  const ReservaSyncNotice({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRefresh,
    this.refreshing = false,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SigadIcon(
                  SigadIcons.sincronizacaoErro,
                  size: 23,
                  color: colors.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: refreshing ? null : onRefresh,
              icon: const SigadIcon(SigadIcons.atualizar, size: 18),
              label: Text(actionLabel),
              style: TextButton.styleFrom(
                foregroundColor: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
