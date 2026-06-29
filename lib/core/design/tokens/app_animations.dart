import 'package:flutter/material.dart';

/// Standard animation durations and curves for the design system.
abstract final class AppAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 600);

  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;

  static AnimatedSwitcherTransitionBuilder fadeTransition =
      (child, animation) {
    return FadeTransition(opacity: animation, child: child);
  };

  static AnimatedSwitcherTransitionBuilder scaleFadeTransition =
      (child, animation) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
      child: FadeTransition(opacity: animation, child: child),
    );
  };
}
