import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_palette.dart';
import 'package:restobill/core/design/tokens/app_radius.dart';

/// Elevation levels and shadow definitions for depth hierarchy.
abstract final class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 4;
  static const double level4 = 8;

  static List<BoxShadow> shadow(
    int level, {
    required Brightness brightness,
  }) {
    final opacity = brightness == Brightness.light ? 0.08 : 0.24;
    final blur = switch (level) {
      0 => 0.0,
      1 => 4.0,
      2 => 8.0,
      3 => 16.0,
      4 => 24.0,
      _ => 8.0,
    };
    final offsetY = switch (level) {
      0 => 0.0,
      1 => 1.0,
      2 => 2.0,
      3 => 4.0,
      4 => 8.0,
      _ => 2.0,
    };

    if (level == 0) return const [];

    return [
      BoxShadow(
        color: AppPalette.charcoal.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, offsetY),
        spreadRadius: 0,
      ),
    ];
  }

  static BoxDecoration cardDecoration({
    required Color backgroundColor,
    required Brightness brightness,
    int level = 1,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? AppRadius.radiusLg,
      border: border,
      boxShadow: shadow(level, brightness: brightness),
    );
  }
}
