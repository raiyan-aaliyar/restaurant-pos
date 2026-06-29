import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_spacing.dart';
import 'package:restobill/core/utils/responsive.dart';

/// Section title with optional subtitle and trailing action widget.
///
/// Use to divide screen content into logical groups — "Active Orders",
/// "Popular Items", "Today's Summary", etc.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.screenTypeOf(context);
    final isCompact = screenType == ScreenType.mobile;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleRow(
                  title: title,
                  action: action,
                  actionLabel: actionLabel,
                  onActionTap: onActionTap,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null)
                  action!
                else if (actionLabel != null && onActionTap != null)
                  TextButton(
                    onPressed: onActionTap,
                    child: Text(actionLabel!),
                  ),
              ],
            ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.title,
    this.action,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (action != null)
          action!
        else if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
