import 'package:flutter/material.dart';

/// Typography scale for the "Vibrant Pulse" design system.
///
/// Headlines use Poppins, body/label text uses Inter. Font weights, sizes,
/// line heights and letter spacing mirror `vibrant_pulse/DESIGN.md`.
///
/// Note: the `Poppins`/`Inter` font assets are not bundled in this project,
/// so Flutter falls back to the platform default font family while keeping
/// the design system's sizing, weight, line-height and letter-spacing.
class AppTypography {
  AppTypography._();

  static const String headlineFontFamily = 'Poppins';
  static const String bodyFontFamily = 'Inter';

  static const TextStyle headlineLg = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  /// Section headers (18px, semibold).
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: headlineFontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: bodyFontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
  );
}
