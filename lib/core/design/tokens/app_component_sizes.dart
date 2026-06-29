import 'package:flutter/material.dart';
import 'package:restobill/core/utils/responsive.dart';

/// Standard component dimensions with responsive scaling.
abstract final class AppComponentSizes {
  static double buttonHeight(BuildContext context) {
    return switch (Responsive.screenTypeOf(context)) {
      ScreenType.mobile => 48,
      ScreenType.tablet => 52,
      ScreenType.largeTablet => 56,
    };
  }

  static double buttonHeightCompact(BuildContext context) {
    return switch (Responsive.screenTypeOf(context)) {
      ScreenType.mobile => 40,
      ScreenType.tablet => 44,
      ScreenType.largeTablet => 48,
    };
  }

  static double inputHeight(BuildContext context) {
    return switch (Responsive.screenTypeOf(context)) {
      ScreenType.mobile => 48,
      ScreenType.tablet => 52,
      ScreenType.largeTablet => 56,
    };
  }

  static double chipHeight(BuildContext context) {
    return switch (Responsive.screenTypeOf(context)) {
      ScreenType.mobile => 36,
      ScreenType.tablet => 40,
      ScreenType.largeTablet => 44,
    };
  }

  static double iconButtonSize(BuildContext context) {
    return switch (Responsive.screenTypeOf(context)) {
      ScreenType.mobile => 44,
      ScreenType.tablet => 48,
      ScreenType.largeTablet => 52,
    };
  }

  static double minTouchTarget = 48;

  static double contentMaxWidth(ScreenType type) => switch (type) {
        ScreenType.mobile => double.infinity,
        ScreenType.tablet => 720,
        ScreenType.largeTablet => 1080,
      };

  static EdgeInsets screenPadding(ScreenType type) => switch (type) {
        ScreenType.mobile => const EdgeInsets.all(16),
        ScreenType.tablet => const EdgeInsets.all(24),
        ScreenType.largeTablet => const EdgeInsets.all(32),
      };
}
