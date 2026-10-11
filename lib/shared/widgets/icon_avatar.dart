import 'package:flutter/material.dart';
import 'package:sigad/app/theme/sigad_icon.dart';

/// Selo circular/arredondado colorido usado para dar identidade visual a
/// cabeçalhos de painel, linhas de lista e cards de atalho.
class SigadIconAvatar extends StatelessWidget {
  const SigadIconAvatar({
    super.key,
    required this.icon,
    required this.tone,
    this.size = 38,
    this.iconSize,
    this.borderRadius = 12,
  });

  final IconData icon;
  final Color tone;
  final double size;
  final double? iconSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SigadIcon(icon, color: tone, size: iconSize ?? size * 0.5),
    );
  }
}
