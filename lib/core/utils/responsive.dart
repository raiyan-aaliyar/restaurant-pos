import 'package:flutter/material.dart';
import 'package:restobill/core/constants/breakpoints.dart';

/// Device form factors supported by the POS layout system.
enum ScreenType {
  mobile,
  tablet,
  largeTablet,
}

/// Utility helpers for responsive layout decisions.
abstract final class Responsive {
  static ScreenType screenTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.largeTablet) {
      return ScreenType.largeTablet;
    }
    if (width >= Breakpoints.tablet) {
      return ScreenType.tablet;
    }
    return ScreenType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      screenTypeOf(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      screenTypeOf(context) == ScreenType.tablet;

  static bool isLargeTablet(BuildContext context) =>
      screenTypeOf(context) == ScreenType.largeTablet;

  static bool useNavigationRail(BuildContext context) =>
      !isMobile(context);

  static String screenTypeLabel(ScreenType type) => switch (type) {
        ScreenType.mobile => 'Mobile',
        ScreenType.tablet => 'Tablet',
        ScreenType.largeTablet => 'Large Tablet',
      };

  static double contentMaxWidth(ScreenType type) => switch (type) {
        ScreenType.mobile => double.infinity,
        ScreenType.tablet => 720,
        ScreenType.largeTablet => 960,
      };

  static EdgeInsets screenPadding(ScreenType type) => switch (type) {
        ScreenType.mobile => const EdgeInsets.all(16),
        ScreenType.tablet => const EdgeInsets.all(24),
        ScreenType.largeTablet => const EdgeInsets.all(32),
      };
}
