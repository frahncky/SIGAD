import 'package:flutter/material.dart';

import 'sigad_colors.dart';

/// Paleta rotativa usada para diferenciar visualmente itens de uma mesma
/// grade ou lista (atalhos, categorias, ícones de configuração) sem sair da
/// paleta institucional do SIGAD.
const List<Color> sigadTonePalette = [
  SigadColors.brand,
  SigadColors.info,
  SigadColors.warning,
  SigadColors.success,
  SigadColors.accent,
  SigadColors.risk,
];

Color sigadToneForIndex(int index) =>
    sigadTonePalette[index % sigadTonePalette.length];
