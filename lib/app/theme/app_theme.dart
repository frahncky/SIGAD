import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sigad_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: SigadColors.brand,
        brightness: Brightness.light,
      ).copyWith(
        surface: SigadColors.surface,
        primary: SigadColors.brand,
        secondary: SigadColors.accent,
      ),
      scaffoldBackgroundColor: SigadColors.canvas,
      textTheme: textTheme.apply(
        bodyColor: SigadColors.ink,
        displayColor: SigadColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SigadColors.surface,
        elevation: 2,
        centerTitle: false,
        surfaceTintColor: SigadColors.surface,
        shadowColor: Colors.black12,
      ),
      cardTheme: CardThemeData(
        color: SigadColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerColor: SigadColors.divider,
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: SigadColors.divider),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SigadColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: SigadColors.divider, width: 1.5),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          highlightColor: SigadColors.brand.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
