import 'package:flutter/material.dart';

/// Color tokens for the "Vibrant Pulse" design system.
///
/// Values are sourced from `vibrant_pulse/DESIGN.md` (Material 3 dark
/// color roles) and the accompanying Stitch HTML mockups.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Vibrant Pulse - Material 3 dark color roles
  // ---------------------------------------------------------------------
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF3A3939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFBDCBB2);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);
  static const Color outline = Color(0xFF88957E);
  static const Color outlineVariant = Color(0xFF3E4A37);
  static const Color surfaceTint = Color(0xFF67E037);
  static const Color surfaceVariant = Color(0xFF353534);
  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE5E2E1);

  static const Color primaryAccent = Color(0xFF79F349);
  static const Color onPrimaryAccent = Color(0xFF0E3900);
  static const Color primaryContainer = Color(0xFF5DD62C);
  static const Color onPrimaryContainer = Color(0xFF1A5800);
  static const Color inversePrimary = Color(0xFF226D00);

  static const Color secondary = Color(0xFF91D971);
  static const Color onSecondary = Color(0xFF0E3900);
  static const Color secondaryContainer = Color(0xFF1E5F00);
  static const Color onSecondaryContainer = Color(0xFF91D870);

  static const Color tertiary = Color(0xFFDAD8D7);
  static const Color onTertiary = Color(0xFF303030);
  static const Color tertiaryContainer = Color(0xFFBEBCBC);
  static const Color onTertiaryContainer = Color(0xFF4C4C4B);

  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorDark = Color(0xFFFFB4AB);

  static const Color primaryFixed = Color(0xFF83FE52);
  static const Color primaryFixedDim = Color(0xFF67E037);
  static const Color onPrimaryFixed = Color(0xFF052100);
  static const Color onPrimaryFixedVariant = Color(0xFF185200);
  static const Color secondaryFixed = Color(0xFFACF68A);
  static const Color secondaryFixedDim = Color(0xFF91D971);
  static const Color onSecondaryFixed = Color(0xFF062100);
  static const Color onSecondaryFixedVariant = Color(0xFF195200);
  static const Color tertiaryFixed = Color(0xFFE5E2E1);
  static const Color tertiaryFixedDim = Color(0xFFC8C6C5);
  static const Color onTertiaryFixed = Color(0xFF1B1C1C);
  static const Color onTertiaryFixedVariant = Color(0xFF474746);

  // ---------------------------------------------------------------------
  // Brand shortcuts (from the DESIGN.md narrative "Colors" section)
  // ---------------------------------------------------------------------
  /// Main dark canvas (#0F0F0F) - used for the splash/auth screens base.
  static const Color obsidian = Color(0xFF0F0F0F);

  /// Card / sheet / input surface (#202020).
  static const Color cardSurface = Color(0xFF202020);

  /// "Pulse" vibrant green - primary actions and active states.
  static const Color vibrantGreen = Color(0xFF5DD62C);

  // ---------------------------------------------------------------------
  // Existing public API kept for backward compatibility with other
  // features that already reference these constants.
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFF5DD62C);
  static const Color primaryDark = Color(0xFF337418);
  static const Color accent = Color(0xFF5DD62C);
  static const Color white = Color(0xFFF8F8F8);
  static const Color black = Color(0xFF0F0F0F);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF5DD62C);
  static const Color warning = Color(0xFFFFC107);
  static const Color surfaceLight = Color(0xFFF8F8F8);
  static const Color surfaceDark = Color(0xFF0F0F0F);
  static const Color surfaceCard = Color(0xFF202020);
}
