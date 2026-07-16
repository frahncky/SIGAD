import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';

abstract final class DemandasVisuals {
  static Color toneStatus(String status) {
    switch (status) {
      case 'Novo':
        return SigadColors.brand;
      case 'Em andamento':
        return SigadColors.info;
      case 'Aguardando':
        return SigadColors.warning;
      case 'Revisão':
        return SigadColors.accent;
      case 'Concluído':
        return SigadColors.success;
      default:
        return SigadColors.muted;
    }
  }

  static Color tonePrioridade(String prioridade) {
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
