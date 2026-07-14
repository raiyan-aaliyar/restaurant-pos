import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yarpay/core/constants/app_constants.dart';
import 'package:yarpay/core/design/theme/app_design_extension.dart';
import 'package:yarpay/core/design/tokens/app_component_sizes.dart';
import 'package:yarpay/core/design/tokens/app_palette.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';
import 'package:yarpay/core/design/tokens/app_typography.dart';

/// Builds premium Material 3 themes from the RestoBill design tokens.
abstract final class AppThemeBuilder {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static String get themeAnimationHeroTag =>
      '${AppConstants.appName}_theme_toggle';

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final design = isLight ? AppDesignExtension.light : AppDesignExtension.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      primaryContainer: isLight
          ? AppPalette.primaryContainer
          : AppPalette.primaryDark.withValues(alpha: 0.4),
      onPrimaryContainer: isLight
          ? AppPalette.onPrimaryContainer
          : AppPalette.primaryLight,
      secondary: isLight ? AppPalette.charcoal : AppPalette.charcoalLight,
      onSecondary: isLight ? Colors.white : AppPalette.darkTextPrimary,
      secondaryContainer:
          isLight ? AppPalette.lightGrey : AppPalette.charcoalElevated,
      onSecondaryContainer: isLight
          ? AppPalette.lightTextPrimary
          : AppPalette.darkTextPrimary,
      tertiary: AppPalette.success,
      onTertiary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      errorContainer: design.errorContainer,
      onErrorContainer: isLight ? AppPalette.errorDark : AppPalette.errorLight,
      surface: isLight ? AppPalette.softWhite : AppPalette.charcoal,
      onSurface: isLight
          ? AppPalette.lightTextPrimary
          : AppPalette.darkTextPrimary,
      onSurfaceVariant: isLight
          ? AppPalette.lightTextSecondary
          : AppPalette.darkTextSecondary,
      outline: design.cardBorder,
      outlineVariant: design.divider,
      shadow: AppPalette.charcoal,
      scrim: AppPalette.scrim,
      inverseSurface: isLight ? AppPalette.charcoal : AppPalette.softWhite,
      onInverseSurface: isLight
          ? AppPalette.darkTextPrimary
          : AppPalette.lightTextPrimary,
      inversePrimary: AppPalette.primaryLight,
      surfaceContainerHighest:
          isLight ? AppPalette.lightGrey : AppPalette.charcoalElevated,
      surfaceContainerHigh:
          isLight ? AppPalette.lightGreyDark : AppPalette.charcoalLight,
      surfaceContainer: isLight ? AppPalette.softWhite : AppPalette.charcoal,
      surfaceContainerLow:
          isLight ? AppPalette.softWhite : AppPalette.charcoal,
      surfaceContainerLowest:
          isLight ? Colors.white : AppPalette.charcoal,
    );

    final textTheme = AppTypography.textTheme(brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [design],
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.headlineMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(color: colorScheme.primary);
          }
          return textTheme.labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: design.cardBackground,
        indicatorColor: colorScheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme:
            IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: design.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(color: design.cardBorder, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: design.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: design.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: design.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: design.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: design.inputBorderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: design.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(64, AppComponentSizes.minTouchTarget),
          padding: AppSpacing.horizontalXl + AppSpacing.verticalMd,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(64, AppComponentSizes.minTouchTarget),
          padding: AppSpacing.horizontalXl + AppSpacing.verticalMd,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          side: BorderSide(color: design.cardBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: design.inputBackground,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium!,
        side: BorderSide(color: design.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusFull),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: design.divider,
      ),
    );
  }
}
