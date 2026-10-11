import 'package:flutter/material.dart';
import '../../app/theme/sigad_colors.dart';
import '../../app/theme/sigad_icons.dart';
import '../../core/config/institutional_context.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SigadColors.brand, SigadColors.brandDeep],
            ),
            borderRadius: BorderRadius.circular(compact ? 12 : 15),
            boxShadow: [
              BoxShadow(
                color: SigadColors.brand.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            SigadIcons.professor,
            color: Colors.white,
            size: compact ? 21 : 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SIGAD',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact ? textTheme.titleMedium : textTheme.headlineSmall)
                        ?.copyWith(
                          color: light ? Colors.white : SigadColors.brandDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
              ),
              Text(
                compact
                    ? '${InstitutionalContext.acronym} • Monte Castelo'
                    : '${InstitutionalContext.acronym} — ${InstitutionalContext.campus}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: light
                      ? Colors.white.withValues(alpha: 0.72)
                      : SigadColors.muted,
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
