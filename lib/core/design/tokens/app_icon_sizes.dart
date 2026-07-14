import 'package:flutter/material.dart';
import 'package:yarpay/core/utils/responsive.dart';

/// Standard icon sizing scale with responsive scaling.
abstract final class AppIconSizes {
  static const double xs = 14;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double hero = 56;

  static double scaled(BuildContext context, double base) {
    final type = Responsive.screenTypeOf(context);
    return switch (type) {
      ScreenType.mobile => base,
      ScreenType.tablet => base * 1.1,
      ScreenType.largeTablet => base * 1.15,
    };
  }
}
