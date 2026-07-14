import 'package:flutter/material.dart';
import 'package:yarpay/core/design/theme/app_design_extension.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/design/tokens/app_elevation.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';

/// Premium card container for POS menu items, order rows, and metric tiles.
///
/// Supports optional tap interaction, Hero transitions, and animated elevation.
class POSCard extends StatefulWidget {
  const POSCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.heroTag,
    this.elevationLevel = 1,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Object? heroTag;
  final int elevationLevel;
  final bool selected;

  @override
  State<POSCard> createState() => _POSCardState();
}

class _POSCardState extends State<POSCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final brightness = Theme.of(context).brightness;
    final colorScheme = Theme.of(context).colorScheme;
    final level = widget.selected ? widget.elevationLevel + 1 : widget.elevationLevel;
    final isInteractive = widget.onTap != null;

    Widget card = AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.standard,
      decoration: AppElevation.cardDecoration(
        backgroundColor: widget.selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : design.cardBackground,
        brightness: brightness,
        level: _pressed ? level + 1 : level,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: widget.selected ? colorScheme.primary : design.cardBorder,
          width: widget.selected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: isInteractive ? (_) => setState(() => _pressed = true) : null,
          onTapUp: isInteractive ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: isInteractive ? () => setState(() => _pressed = false) : null,
          borderRadius: AppRadius.radiusLg,
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: widget.padding ?? AppSpacing.insetLg,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      card = Hero(
        tag: widget.heroTag!,
        child: Material(
          color: Colors.transparent,
          child: card,
        ),
      );
    }

    return card;
  }
}
