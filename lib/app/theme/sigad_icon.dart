import 'package:flutter/material.dart';

import 'sigad_colors.dart';
import 'sigad_icons.dart';

/// Desenha um ícone do SIGAD com suas duas camadas.
///
/// O traço principal segue [color] (ou o [IconTheme] atual), como um [Icon]
/// comum. O destaque usa [accentColor], que por padrão é a cor de destaque
/// do logotipo ([SigadColors.accent]). Quando o ícone está esmaecido
/// (cor ou tema com transparência, como em botões desabilitados), o destaque
/// acompanha a cor do traço para não chamar atenção indevida.
///
/// Ícones que não pertencem à fonte `SigadIcons` são desenhados como um
/// [Icon] normal.
class SigadIcon extends StatelessWidget {
  const SigadIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.accentColor,
    this.semanticLabel,
  });

  final IconData? icon;
  final double? size;
  final Color? color;
  final Color? accentColor;
  final String? semanticLabel;

  /// Ampliação aplicada a todos os ícones para facilitar a leitura.
  static const escala = 1.1;

  @override
  Widget build(BuildContext context) {
    final size = (this.size ?? IconTheme.of(context).size ?? 24) * escala;
    final principal = Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
    final iconData = icon;
    final destaque = iconData == null ? null : SigadIcons.destaqueDe(iconData);
    if (destaque == null) return principal;

    final tema = IconTheme.of(context);
    final corPrincipal = color ?? tema.color;
    final esmaecido =
        (tema.opacity ?? 1) < 1 || (corPrincipal != null && corPrincipal.a < 1);
    final corDestaque = esmaecido
        ? corPrincipal
        : accentColor ?? SigadColors.accent;

    return Stack(
      alignment: Alignment.center,
      children: [
        principal,
        ExcludeSemantics(
          child: Icon(destaque, size: size, color: corDestaque),
        ),
      ],
    );
  }
}
