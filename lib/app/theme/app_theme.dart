import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sigad_colors.dart';

/// Temas visuais do SIGAD.
///
/// O tema concentra tipografia, espaçamentos, campos, cartões e navegação para
/// que todas as páginas mantenham a mesma linguagem visual.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _textTheme(base.textTheme).apply(
      bodyColor: SigadColors.ink,
      displayColor: SigadColors.ink,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: SigadColors.brand,
      brightness: Brightness.light,
      surface: SigadColors.surface,
    ).copyWith(
      primary: SigadColors.brand,
      onPrimary: Colors.white,
      primaryContainer: SigadColors.brandLight,
      onPrimaryContainer: SigadColors.brandDark,
      secondary: SigadColors.accent,
      secondaryContainer: SigadColors.accentSoft,
      error: SigadColors.risk,
      surface: SigadColors.surface,
      surfaceContainerLowest: SigadColors.surface,
      surfaceContainerLow: SigadColors.surfaceWarm,
      surfaceContainer: SigadColors.surfaceAlt,
      surfaceContainerHigh: SigadColors.brandLight,
      outline: SigadColors.divider,
      outlineVariant: SigadColors.divider,
      onSurface: SigadColors.ink,
      onSurfaceVariant: SigadColors.muted,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SigadColors.canvas,
      textTheme: textTheme,
      dividerColor: SigadColors.divider,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: SigadColors.surface,
        foregroundColor: SigadColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        surfaceTintColor: SigadColors.surface,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: SigadColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 8,
        backgroundColor: SigadColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        indicatorColor: SigadColors.brandLight,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: states.contains(WidgetState.selected) ? 25 : 23,
            color: states.contains(WidgetState.selected)
                ? SigadColors.brand
                : SigadColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? SigadColors.brand
                : SigadColors.muted,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: SigadColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: SigadColors.divider),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: SigadColors.surface,
        selectedColor: SigadColors.brandLight,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: SigadColors.muted,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: SigadColors.brandDark,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: SigadColors.divider),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SigadColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        prefixIconColor: SigadColors.muted,
        suffixIconColor: SigadColors.muted,
        labelStyle: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: SigadColors.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SigadColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SigadColors.brand, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SigadColors.risk),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SigadColors.risk, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          backgroundColor: SigadColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SigadColors.divider,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: SigadColors.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: SigadColors.divider, width: 1.2),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SigadColors.brand,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SigadColors.brand,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SigadColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SigadColors.surface,
        surfaceTintColor: SigadColors.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: SigadColors.ink,
          highlightColor: SigadColors.brandLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: SigadColors.muted,
        textColor: SigadColors.ink,
        minVerticalPadding: 10,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  static ThemeData dark() {
    const canvasDark = Color(0xFF0D1715);
    const surfaceDark = Color(0xFF162521);
    const surfaceAltDark = Color(0xFF20332E);
    const inkDark = Color(0xFFE8F0ED);
    const mutedDark = Color(0xFF9AAEA8);
    const dividerDark = Color(0xFF31453F);

    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _textTheme(base.textTheme).apply(
      bodyColor: inkDark,
      displayColor: inkDark,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: SigadColors.brand,
      brightness: Brightness.dark,
      surface: surfaceDark,
    ).copyWith(
      primary: const Color(0xFF63C8B4),
      onPrimary: SigadColors.brandDeep,
      primaryContainer: const Color(0xFF174F45),
      secondary: const Color(0xFFFFBE70),
      surface: surfaceDark,
      surfaceContainerLowest: canvasDark,
      surfaceContainerLow: surfaceDark,
      surfaceContainer: surfaceAltDark,
      surfaceContainerHigh: const Color(0xFF29413A),
      outline: dividerDark,
      outlineVariant: dividerDark,
      onSurface: inkDark,
      onSurfaceVariant: mutedDark,
      error: const Color(0xFFFFB4AB),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvasDark,
      textTheme: textTheme,
      dividerColor: dividerDark,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: inkDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        surfaceTintColor: surfaceDark,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: inkDark,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 8,
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF244F46),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: states.contains(WidgetState.selected) ? 25 : 23,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF63C8B4)
                : mutedDark,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF63C8B4)
                : mutedDark,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: surfaceDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: dividerDark),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceDark,
        selectedColor: const Color(0xFF244F46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: dividerDark),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        prefixIconColor: mutedDark,
        suffixIconColor: mutedDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF63C8B4), width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: dividerDark, width: 1.2),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: inkDark,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: canvasDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: surfaceDark,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: mutedDark,
        textColor: inkDark,
        minVerticalPadding: 10,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    final source = GoogleFonts.config.allowRuntimeFetching
        ? GoogleFonts.spaceGroteskTextTheme(base)
        : base;

    return source.copyWith(
      displayLarge: source.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      headlineLarge: source.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      headlineMedium: source.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: source.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
      ),
      titleLarge: source.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      titleMedium: source.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: source.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: source.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: source.bodyMedium?.copyWith(height: 1.35),
      bodySmall: source.bodySmall?.copyWith(height: 1.3),
    );
  }
}
