import 'package:flutter/material.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/design/tokens/app_component_sizes.dart';
import 'package:yarpay/core/design/tokens/app_icon_sizes.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';

/// Selectable filter chip for menu categories, order status, and quick filters.
///
/// Use in horizontal scrollable rows above content lists or grids.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.count,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = AppComponentSizes.chipHeight(context);

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.standard,
      height: height,
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusFull,
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(!selected),
          borderRadius: AppRadius.radiusFull,
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  AnimatedSwitcher(
                    duration: AppAnimations.fast,
                    child: Icon(
                      icon,
                      key: ValueKey('$selected-$icon'),
                      size: AppIconSizes.sm,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                  child: Text(label),
                ),
                if (count != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedContainer(
                    duration: AppAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: AppRadius.radiusFull,
                    ),
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
