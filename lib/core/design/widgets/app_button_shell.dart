import 'package:flutter/material.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/design/tokens/app_component_sizes.dart';
import 'package:yarpay/core/design/tokens/app_icon_sizes.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';

/// Shared button configuration used by [PrimaryButton] and [SecondaryButton].
class AppButtonConfig {
  const AppButtonConfig({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final bool compact;
}

/// Internal animated button shell shared by primary and secondary variants.
class AppButtonShell extends StatefulWidget {
  const AppButtonShell({
    super.key,
    required this.config,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.border,
    this.elevation = 0,
    this.pressedBackgroundColor,
  });

  final AppButtonConfig config;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide border;
  final double elevation;
  final Color? pressedBackgroundColor;

  @override
  State<AppButtonShell> createState() => _AppButtonShellState();
}

class _AppButtonShellState extends State<AppButtonShell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final height = config.compact
        ? AppComponentSizes.buttonHeightCompact(context)
        : AppComponentSizes.buttonHeight(context);
    final enabled = config.onPressed != null && !config.isLoading;

    final child = AnimatedContainer(
      duration: AppAnimations.fast,
      curve: AppAnimations.standard,
      height: height,
      width: config.isExpanded ? double.infinity : null,
      decoration: BoxDecoration(
        color: _pressed && enabled
            ? (widget.pressedBackgroundColor ?? widget.backgroundColor)
            : widget.backgroundColor,
        borderRadius: AppRadius.radiusMd,
        border: Border.fromBorderSide(widget.border),
        boxShadow: enabled && widget.elevation > 0
            ? [
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.35),
                  blurRadius: _pressed ? 4 : 8,
                  offset: Offset(0, _pressed ? 1 : 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? config.onPressed : null,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          borderRadius: AppRadius.radiusMd,
          splashColor: widget.foregroundColor.withValues(alpha: 0.12),
          highlightColor: widget.foregroundColor.withValues(alpha: 0.08),
          child: Padding(
            padding: AppSpacing.horizontalXl,
            child: AnimatedSwitcher(
              duration: AppAnimations.fast,
              child: config.isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: AppIconSizes.md,
                      height: AppIconSizes.md,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.foregroundColor,
                      ),
                    )
                  : Row(
                      key: const ValueKey('content'),
                      mainAxisSize:
                          config.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (config.icon != null) ...[
                          Icon(
                            config.icon,
                            size: AppIconSizes.md,
                            color: widget.foregroundColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          config.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: widget.foregroundColor,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: config.label,
      child: child,
    );
  }
}
