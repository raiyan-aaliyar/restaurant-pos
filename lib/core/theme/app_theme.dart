import 'package:flutter/material.dart';
import 'package:restobill/core/design/theme/app_theme_builder.dart';

export 'package:restobill/core/design/theme/app_theme_builder.dart';

/// Material 3 light and dark themes for the POS application.
abstract final class AppTheme {
  static ThemeData get light => AppThemeBuilder.light;
  static ThemeData get dark => AppThemeBuilder.dark;
  static String get themeAnimationHeroTag => AppThemeBuilder.themeAnimationHeroTag;
}
