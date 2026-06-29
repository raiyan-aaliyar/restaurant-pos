import 'package:flutter/material.dart';

/// Restaurant-inspired brand and semantic color palette.
abstract final class AppPalette {
  // Brand — warm orange
  static const Color primary = Color(0xFFE8650A);
  static const Color primaryLight = Color(0xFFFF8A3D);
  static const Color primaryDark = Color(0xFFC4550A);
  static const Color primaryContainer = Color(0xFFFFE8D6);
  static const Color onPrimaryContainer = Color(0xFF4A1F00);

  // Neutrals — light theme
  static const Color softWhite = Color(0xFFFAFAF8);
  static const Color lightGrey = Color(0xFFF2F2F0);
  static const Color lightGreyDark = Color(0xFFE5E5E3);
  static const Color lightBorder = Color(0xFFD8D8D6);
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF6B6B6E);

  // Neutrals — dark theme
  static const Color charcoal = Color(0xFF2C2C2E);
  static const Color charcoalLight = Color(0xFF3A3A3C);
  static const Color charcoalElevated = Color(0xFF444446);
  static const Color darkBorder = Color(0xFF525254);
  static const Color darkTextPrimary = Color(0xFFF5F5F3);
  static const Color darkTextSecondary = Color(0xFFAEAEAE);

  // Semantic
  static const Color success = Color(0xFF3D9A6A);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color successDark = Color(0xFF2A7A52);

  static const Color warning = Color(0xFFE6A817);
  static const Color warningLight = Color(0xFFFFF4D6);
  static const Color warningDark = Color(0xFFC48A0F);

  static const Color error = Color(0xFFD64545);
  static const Color errorLight = Color(0xFFFDEDED);
  static const Color errorDark = Color(0xFFB53535);

  // Overlays
  static const Color scrim = Color(0x99000000);
  static const Color shimmerBase = Color(0xFFE8E8E6);
  static const Color shimmerHighlight = Color(0xFFF8F8F6);
  static const Color shimmerBaseDark = Color(0xFF3A3A3C);
  static const Color shimmerHighlightDark = Color(0xFF4A4A4C);
}
