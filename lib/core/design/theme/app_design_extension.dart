import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_palette.dart';

/// Theme extension exposing semantic design tokens beyond [ColorScheme].
@immutable
class AppDesignExtension extends ThemeExtension<AppDesignExtension> {
  const AppDesignExtension({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.cardBackground,
    required this.cardBorder,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.divider,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color cardBackground;
  final Color cardBorder;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputBorderFocused;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color divider;

  static AppDesignExtension light = const AppDesignExtension(
    success: AppPalette.success,
    onSuccess: Colors.white,
    successContainer: AppPalette.successLight,
    warning: AppPalette.warning,
    onWarning: AppPalette.lightTextPrimary,
    warningContainer: AppPalette.warningLight,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorLight,
    cardBackground: AppPalette.softWhite,
    cardBorder: AppPalette.lightBorder,
    inputBackground: AppPalette.lightGrey,
    inputBorder: AppPalette.lightBorder,
    inputBorderFocused: AppPalette.primary,
    shimmerBase: AppPalette.shimmerBase,
    shimmerHighlight: AppPalette.shimmerHighlight,
    divider: AppPalette.lightGreyDark,
  );

  static AppDesignExtension dark = const AppDesignExtension(
    success: AppPalette.success,
    onSuccess: Colors.white,
    successContainer: Color(0xFF1A3D2A),
    warning: AppPalette.warning,
    onWarning: AppPalette.darkTextPrimary,
    warningContainer: Color(0xFF3D3010),
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: Color(0xFF3D1A1A),
    cardBackground: AppPalette.charcoalLight,
    cardBorder: AppPalette.darkBorder,
    inputBackground: AppPalette.charcoalElevated,
    inputBorder: AppPalette.darkBorder,
    inputBorderFocused: AppPalette.primaryLight,
    shimmerBase: AppPalette.shimmerBaseDark,
    shimmerHighlight: AppPalette.shimmerHighlightDark,
    divider: AppPalette.darkBorder,
  );

  @override
  AppDesignExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? cardBackground,
    Color? cardBorder,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputBorderFocused,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? divider,
  }) {
    return AppDesignExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputBorderFocused: inputBorderFocused ?? this.inputBorderFocused,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppDesignExtension lerp(covariant ThemeExtension<AppDesignExtension>? other, double t) {
    if (other is! AppDesignExtension) return this;
    return AppDesignExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputBorderFocused:
          Color.lerp(inputBorderFocused, other.inputBorderFocused, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Convenience accessor for [AppDesignExtension] from [BuildContext].
extension AppDesignContext on BuildContext {
  AppDesignExtension get design =>
      Theme.of(this).extension<AppDesignExtension>()!;
}
