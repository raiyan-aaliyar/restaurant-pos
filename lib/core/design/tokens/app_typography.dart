import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_palette.dart';
import 'package:restobill/core/utils/responsive.dart';

/// Typography scale for the RestoBill design system.
abstract final class AppTypography {
  static const String _fontFamily = 'Roboto';

  static TextTheme textTheme({required Brightness brightness}) {
    final primary = brightness == Brightness.light
        ? AppPalette.lightTextPrimary
        : AppPalette.darkTextPrimary;
    final secondary = brightness == Brightness.light
        ? AppPalette.lightTextSecondary
        : AppPalette.darkTextSecondary;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.2,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        height: 1.4,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        height: 1.4,
        color: secondary,
      ),
    );
  }

  /// Returns a scaled font size based on the current screen type.
  static double scaledFontSize(BuildContext context, double base) {
    final type = Responsive.screenTypeOf(context);
    return switch (type) {
      ScreenType.mobile => base,
      ScreenType.tablet => base * 1.05,
      ScreenType.largeTablet => base * 1.1,
    };
  }
}
