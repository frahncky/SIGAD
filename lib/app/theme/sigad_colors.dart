import 'package:flutter/material.dart';

/// Paleta institucional do SIGAD.
///
/// As cores foram organizadas por função para evitar valores soltos nas telas
/// e facilitar a manutenção dos temas claro e escuro.
abstract final class SigadColors {
  static const Color brand = Color(0xFF0B6B5E);
  static const Color brandDark = Color(0xFF064C43);
  static const Color brandDeep = Color(0xFF033B35);
  static const Color brandLight = Color(0xFFE7F3EF);

  static const Color accent = Color(0xFFE59A3A);
  static const Color accentSoft = Color(0xFFFFEBD3);

  static const Color canvas = Color(0xFFF5F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F4F2);
  static const Color surfaceWarm = Color(0xFFFAF7F2);

  static const Color ink = Color(0xFF172522);
  static const Color muted = Color(0xFF64736F);
  static const Color divider = Color(0xFFDDE5E1);

  static const Color info = Color(0xFF2F6F91);
  static const Color infoSoft = Color(0xFFE7F1F7);
  static const Color success = Color(0xFF1B7F5C);
  static const Color successSoft = Color(0xFFDDF1E8);
  static const Color warning = Color(0xFFB86724);
  static const Color warningSoft = Color(0xFFFFEAD7);
  static const Color risk = Color(0xFFB64040);
  static const Color riskSoft = Color(0xFFF9E1E1);

  static const Color mint = Color(0xFFBFE3D0);
}
