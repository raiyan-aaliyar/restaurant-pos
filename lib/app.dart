import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/core/constants/app_constants.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/router/app_router.dart';
import 'package:yarpay/core/theme/app_theme.dart';
import 'package:yarpay/core/theme/theme_mode_provider.dart';

/// Root application widget configured with theme and routing.
class RestoBillApp extends ConsumerWidget {
  const RestoBillApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: AppAnimations.slow,
      themeAnimationCurve: AppAnimations.standard,
      routerConfig: router,
    );
  }
}
