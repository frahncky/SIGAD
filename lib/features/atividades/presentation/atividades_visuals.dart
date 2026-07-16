import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';

abstract final class AtividadesVisuals {
  static Color statusColor(String status) {
    switch (status) {
      case 'Concluída':
        return SigadColors.success;
      case 'Em progresso':
        return SigadColors.info;
      case 'Agendada':
        return SigadColors.warning;
      case 'Pendente':
        return SigadColors.accent;
      default:
        return SigadColors.muted;
    }
  }
}
