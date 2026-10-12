import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';
import '../../../app/theme/sigad_icons.dart';
import '../domain/mural_models.dart';

/// Ícone e cor de cada modelo de aviso.
extension ModeloAvisoVisual on ModeloAviso {
  IconData get icone => switch (this) {
    ModeloAviso.informativo => SigadIcons.info,
    ModeloAviso.importante => SigadIcons.alerta,
    ModeloAviso.evento => SigadIcons.evento,
    ModeloAviso.lembrete => SigadIcons.alarme,
  };

  Color get cor => switch (this) {
    ModeloAviso.informativo => SigadColors.info,
    ModeloAviso.importante => SigadColors.risk,
    ModeloAviso.evento => SigadColors.success,
    ModeloAviso.lembrete => SigadColors.warning,
  };
}
