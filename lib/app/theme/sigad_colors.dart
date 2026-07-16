import 'package:flutter/material.dart';

/// Paleta institucional do SIGAD.
///
/// As cores foram organizadas por função para evitar valores soltos nas telas
/// e facilitar a manutenção dos temas claro e escuro.
abstract final class SigadColors {
  static const Color brand = Color(0xFF087F6D);
  static const Color brandDark = Color(0xFF056354);
  static const Color brandDeep = Color(0xFF073E37);
  static const Color brandLight = Color(0xFFE5F5F1);

  static const Color accent = Color(0xFFF09A4A);
  static const Color accentSoft = Color(0xFFFFECDD);

  static const Color canvas = Color(0xFFF3F7F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEDF4F2);
  static const Color surfaceWarm = Color(0xFFFBF8F4);

  static const Color ink = Color(0xFF172B27);
  static const Color muted = Color(0xFF637773);
  static const Color divider = Color(0xFFD9E6E2);

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
