import 'package:yarpay/core/design/tokens/app_palette.dart';

export 'package:yarpay/core/design/tokens/app_palette.dart';

/// Backward-compatible alias for [AppPalette] brand colors.
abstract final class AppColors {
  static const seed = AppPalette.primary;
  static const lightSurface = AppPalette.softWhite;
  static const darkSurface = AppPalette.charcoal;
  static const lightCard = AppPalette.lightGrey;
  static const darkCard = AppPalette.charcoalLight;
}
