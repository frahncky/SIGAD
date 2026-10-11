import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sigad_colors.dart';
import 'sigad_icons.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = _textTheme(
      base.textTheme,
    ).apply(bodyColor: SigadColors.ink, displayColor: SigadColors.ink);

    final colors =
        ColorScheme.fromSeed(
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

    return _buildTheme(
      base: base,
      colors: colors,
      textTheme: textTheme,
      canvas: SigadColors.canvas,
      surface: SigadColors.surface,
      divider: SigadColors.divider,
      muted: SigadColors.muted,
      dark: false,
    );
  }

  static ThemeData dark() {
    const canvas = Color(0xFF0D1715);
    const surface = Color(0xFF162521);
    const surfaceAlt = Color(0xFF20332E);
    const ink = Color(0xFFE8F0ED);
    const muted = Color(0xFF9AAEA8);
    const divider = Color(0xFF31453F);

    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = _textTheme(
      base.textTheme,
    ).apply(bodyColor: ink, displayColor: ink);

    final colors =
        ColorScheme.fromSeed(
          seedColor: SigadColors.brand,
          brightness: Brightness.dark,
          surface: surface,
        ).copyWith(
          primary: const Color(0xFF63C8B4),
          onPrimary: SigadColors.brandDeep,
          primaryContainer: const Color(0xFF174F45),
          secondary: const Color(0xFFFFBE70),
          surface: surface,
          surfaceContainerLowest: canvas,
          surfaceContainerLow: surface,
          surfaceContainer: surfaceAlt,
          surfaceContainerHigh: const Color(0xFF29413A),
          outline: divider,
          outlineVariant: divider,
          onSurface: ink,
          onSurfaceVariant: muted,
          error: const Color(0xFFFFB4AB),
        );

    return _buildTheme(
      base: base,
      colors: colors,
      textTheme: textTheme,
      canvas: canvas,
      surface: surface,
      divider: divider,
      muted: muted,
      dark: true,
    );
  }

  static ThemeData _buildTheme({
    required ThemeData base,
    required ColorScheme colors,
    required TextTheme textTheme,
    required Color canvas,
    required Color surface,
    required Color divider,
    required Color muted,
    required bool dark,
  }) {
    return base.copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      dividerColor: divider,
      visualDensity: VisualDensity.standard,
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) => const Icon(SigadIcons.chevronEsquerda),
        closeButtonIconBuilder: (_) => const Icon(SigadIcons.fechar),
        drawerButtonIconBuilder: (_) => const Icon(SigadIcons.menu),
        endDrawerButtonIconBuilder: (_) => const Icon(SigadIcons.menu),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: surface,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.24 : 0.06),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.22 : 0.08),
        indicatorColor: colors.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: states.contains(WidgetState.selected) ? 25 : 23,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : muted,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: dark ? 0.20 : 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: divider),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: colors.primaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: muted,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: divider),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        prefixIconColor: muted,
        suffixIconColor: muted,
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: divider, width: 1.2),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.onSurface,
          highlightColor: colors.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: colors.onSurface,
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
