import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_animations.dart';
import 'package:restobill/core/design/tokens/app_icon_sizes.dart';
import 'package:restobill/core/design/tokens/app_spacing.dart';
import 'package:restobill/core/design/widgets/primary_button.dart';
import 'package:restobill/core/design/widgets/secondary_button.dart';

/// Placeholder UI for lists, search results, or screens with no data yet.
///
/// Use when a collection is empty — no orders, no search results, no menu items.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedSwitcher(
        duration: AppAnimations.normal,
        transitionBuilder: AppAnimations.scaleFadeTransition,
        child: Padding(
          key: ValueKey(title),
          padding: AppSpacing.insetXxl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'empty_state_$title',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: AppIconSizes.xxl,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  isExpanded: true,
                ),
              ],
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction,
                  isExpanded: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
