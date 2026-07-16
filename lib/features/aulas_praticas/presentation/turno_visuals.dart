import 'package:flutter/material.dart';

import '../../../app/theme/sigad_colors.dart';
import '../domain/reserva_models.dart';

extension TurnoVisuals on Turno {
  Color get chipBackground {
    switch (this) {
      case Turno.matutino:
        return SigadColors.successSoft.withValues(alpha: 0.85);
      case Turno.vespertino:
        return SigadColors.accentSoft.withValues(alpha: 0.85);
      case Turno.noturno:
        return SigadColors.surfaceAlt;
    }
  }

  Color get chipTextColor {
    switch (this) {
      case Turno.matutino:
        return SigadColors.success;
      case Turno.vespertino:
        return SigadColors.warning;
      case Turno.noturno:
        return SigadColors.brandDark;
    }
  }
}
