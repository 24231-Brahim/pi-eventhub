import 'package:flutter/material.dart';

/// Spacing scale for the "Vibrant Pulse" design system (8px grid).
class AppSpacing {
  AppSpacing._();

  static const double base = 8;
  static const double containerPadding = 16;
  static const double gutter = 12;
  static const double stackSm = 4;
  static const double stackMd = 16;
  static const double stackLg = 24;
}

/// Corner radius scale for the "Vibrant Pulse" design system.
class AppRadius {
  AppRadius._();

  /// Tags, chips and small badges.
  static const double sm = 8;

  /// Standard elements: cards, inputs, buttons.
  static const double md = 12;

  /// Large elements: bottom sheets, featured hero banners.
  static const double lg = 24;

  /// Fully pill-shaped containers (category chips, indicators).
  static const double full = 9999;
}

/// Elevation shadows for the "Vibrant Pulse" design system.
class AppShadows {
  AppShadows._();

  /// Level 1 elevation: floating cards and inputs.
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
