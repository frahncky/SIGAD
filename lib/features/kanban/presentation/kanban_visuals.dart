import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';

abstract final class KanbanVisuals {
  static Color prioridadeColor(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return SigadColors.risk;
      case 'Média':
        return SigadColors.warning;
      default:
        return SigadColors.success;
    }
  }
}
