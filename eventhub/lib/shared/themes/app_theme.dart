import 'package:flutter/material.dart';
import 'package:eventhub/shared/themes/app_colors.dart';
import 'package:eventhub/shared/themes/app_dimensions.dart';
import 'package:eventhub/shared/themes/app_typography.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryAccent,
    onPrimary: AppColors.onPrimaryAccent,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.errorDark,
    onError: AppColors.onErrorDark,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceDim: AppColors.surfaceDim,
    surfaceBright: AppColors.surfaceBright,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: AppColors.inverseOnSurface,
    inversePrimary: AppColors.inversePrimary,
    surfaceTint: AppColors.surfaceTint,
  );

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.vibrantGreen,
    brightness: Brightness.light,
  );

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: AppTypography.headlineLg.copyWith(color: onSurface),
      displayMedium: AppTypography.headlineMd.copyWith(color: onSurface),
      displaySmall: AppTypography.headlineSm.copyWith(color: onSurface),
      headlineLarge: AppTypography.headlineLgMobile.copyWith(color: onSurface),
      headlineMedium: AppTypography.headlineMd.copyWith(color: onSurface),
      headlineSmall: AppTypography.headlineSm.copyWith(color: onSurface),
      titleLarge: AppTypography.headlineSm.copyWith(color: onSurface),
      titleMedium: AppTypography.labelLg.copyWith(color: onSurface),
      titleSmall: AppTypography.labelMd.copyWith(color: onSurface),
      bodyLarge: AppTypography.bodyLg.copyWith(color: onSurface),
      bodyMedium: AppTypography.bodyMd.copyWith(color: onSurface),
      bodySmall: AppTypography.labelMd.copyWith(color: onSurfaceVariant),
      labelLarge: AppTypography.labelLg.copyWith(color: onSurface),
      labelMedium: AppTypography.labelMd.copyWith(color: onSurfaceVariant),
      labelSmall: AppTypography.labelMd.copyWith(color: onSurfaceVariant),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final scaffoldBackground = isDark ? AppColors.surface : scheme.surface;
    final cardColor = isDark ? AppColors.surfaceContainer : scheme.surfaceContainerHigh;
    final inputFill = isDark ? AppColors.surfaceContainer : scheme.surfaceContainerHighest;
    final buttonBackground = isDark ? AppColors.primaryContainer : scheme.primary;
    final buttonForeground = isDark ? AppColors.obsidian : scheme.onPrimary;
    final navBarSelectedColor = isDark ? AppColors.vibrantGreen : scheme.primary;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: _textTheme(scheme.onSurface, scheme.onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackground,
          foregroundColor: buttonForeground,
          minimumSize: const Size(double.infinity, 48),
          textStyle: AppTypography.labelLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: scheme.outline),
          textStyle: AppTypography.bodyLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        labelStyle: AppTypography.labelMd.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.vibrantGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerPadding,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: AppColors.vibrantGreen,
        labelStyle: AppTypography.bodyMd.copyWith(color: scheme.onSurfaceVariant),
        secondaryLabelStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.obsidian,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.base / 2,
        ),
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: AppColors.vibrantGreen.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelMd.copyWith(
            color: selected ? navBarSelectedColor : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? navBarSelectedColor : scheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }

  static ThemeData get lightTheme => _buildTheme(_lightColorScheme);

  static ThemeData get darkTheme => _buildTheme(_darkColorScheme);
}
