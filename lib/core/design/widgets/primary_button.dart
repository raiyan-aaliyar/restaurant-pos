import 'package:flutter/material.dart';
import 'package:yarpay/core/design/widgets/app_button_shell.dart';

/// Primary call-to-action button with warm orange fill and press animation.
///
/// Use for the main action on a screen — checkout, save, confirm order, etc.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppButtonShell(
      config: AppButtonConfig(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        isExpanded: isExpanded,
        compact: compact,
      ),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      pressedBackgroundColor: colorScheme.primary.withValues(alpha: 0.88),
      border: BorderSide.none,
      elevation: 2,
    );
  }
}
