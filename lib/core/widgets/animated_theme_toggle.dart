import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/design/tokens/app_component_sizes.dart';
import 'package:yarpay/core/design/tokens/app_icon_sizes.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/theme/theme_mode_provider.dart';

/// Animated sun/moon toggle for switching between light and dark themes.
class AnimatedThemeToggle extends ConsumerStatefulWidget {
  const AnimatedThemeToggle({super.key});

  @override
  ConsumerState<AnimatedThemeToggle> createState() =>
      _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends ConsumerState<AnimatedThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onToggle() async {
    await _controller.forward(from: 0);
    ref.read(themeModeProvider.notifier).toggle();
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      child: Semantics(
        button: true,
        label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onToggle,
            borderRadius: AppRadius.radiusXl,
            child: AnimatedContainer(
              duration: AppAnimations.normal,
              curve: AppAnimations.standard,
              width: AppComponentSizes.iconButtonSize(context),
              height: AppComponentSizes.iconButtonSize(context),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.radiusXl,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scale.value,
                    child: Transform.rotate(
                      angle: _rotation.value * 3.14159,
                      child: child,
                    ),
                  );
                },
                child: AnimatedSwitcher(
                  duration: AppAnimations.normal,
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    key: ValueKey(isDark),
                    color: colorScheme.primary,
                    size: AppIconSizes.md,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
