import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';

abstract final class RelatoriosVisuals {
  static Color statusColor(String status) {
    switch (status) {
      case 'Publicado':
      case 'Disponível':
        return SigadColors.success;
      case 'Em revisão':
        return SigadColors.warning;
      case 'Agendado':
        return SigadColors.info;
      default:
        return SigadColors.muted;
    }
  }
}
