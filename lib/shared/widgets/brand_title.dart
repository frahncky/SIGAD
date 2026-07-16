import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';
import '../../core/config/institutional_context.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: compact ? 34 : 40,
          height: compact ? 34 : 40,
          decoration: BoxDecoration(
            color: SigadColors.brand,
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: const Icon(
            Icons.account_balance_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SIGAD',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: colors.onSurface,
                ),
              ),
              Text(
                compact
                    ? '${InstitutionalContext.acronym} • Monte Castelo'
                    : '${InstitutionalContext.acronym} — ${InstitutionalContext.campus}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
