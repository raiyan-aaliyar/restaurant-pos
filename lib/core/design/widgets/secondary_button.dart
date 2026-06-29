import 'package:flutter/material.dart';
import 'package:restobill/core/design/theme/app_design_extension.dart';
import 'package:restobill/core/design/widgets/app_button_shell.dart';

/// Outlined secondary button for non-destructive alternate actions.
///
/// Use for cancel, back, filter, or secondary flows that should not compete
/// with the primary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    final design = context.design;

    return AppButtonShell(
      config: AppButtonConfig(
        label: label,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        isExpanded: isExpanded,
        compact: compact,
      ),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      pressedBackgroundColor: design.inputBackground,
      border: BorderSide(color: design.cardBorder),
    );
  }
}
