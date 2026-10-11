import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';
import '../../app/theme/sigad_icon.dart';
import '../../app/theme/sigad_icons.dart';

class HorizontalScrollHint extends StatelessWidget {
  const HorizontalScrollHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SigadColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SigadColors.divider),
      ),
      child: Row(
        children: [
          const SigadIcon(
            SigadIcons.deslizar,
            size: 18,
            color: SigadColors.brand,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: SigadColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
