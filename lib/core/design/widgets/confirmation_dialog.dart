import 'package:flutter/material.dart';
import 'package:yarpay/core/design/theme/app_design_extension.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';
import 'package:yarpay/core/design/widgets/app_button_shell.dart';
import 'package:yarpay/core/design/widgets/primary_button.dart';
import 'package:yarpay/core/design/widgets/secondary_button.dart';

/// Branded confirmation dialog for destructive or irreversible actions.
///
/// Use before voiding an order, clearing a cart, deleting a menu item, etc.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  /// Shows the dialog and returns `true` if confirmed, `false` if cancelled.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final design = context.design;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      child: Padding(
        padding: AppSpacing.insetXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 40,
                color: isDestructive ? design.error : colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: cancelLabel,
                    onPressed: () => Navigator.of(context).pop(false),
                    compact: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: isDestructive
                      ? AppButtonShell(
                          config: AppButtonConfig(
                            label: confirmLabel,
                            onPressed: () => Navigator.of(context).pop(true),
                            compact: true,
                            isExpanded: true,
                          ),
                          backgroundColor: design.error,
                          foregroundColor: design.onError,
                          pressedBackgroundColor:
                              design.error.withValues(alpha: 0.88),
                          border: BorderSide.none,
                        )
                      : PrimaryButton(
                          label: confirmLabel,
                          onPressed: () => Navigator.of(context).pop(true),
                          compact: true,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
