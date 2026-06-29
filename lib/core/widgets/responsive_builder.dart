import 'package:flutter/material.dart';
import 'package:restobill/core/utils/responsive.dart';

/// Builds different layouts based on the current [ScreenType].
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.largeTablet,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? largeTablet;

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.screenTypeOf(context);

    return switch (screenType) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.largeTablet => largeTablet ?? tablet ?? mobile,
    };
  }
}
