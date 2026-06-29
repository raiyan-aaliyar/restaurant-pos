import 'package:flutter/material.dart';
import 'package:restobill/core/design/tokens/app_component_sizes.dart';
import 'package:restobill/core/utils/responsive.dart';

/// Constrains content width and applies responsive padding per screen type.
///
/// Wrap page-level content to keep layouts readable on tablet and large tablet.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.alignment = Alignment.topCenter,
    this.expand = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.screenTypeOf(context);
    final maxWidth = AppComponentSizes.contentMaxWidth(screenType);
    final defaultPadding = AppComponentSizes.screenPadding(screenType);

    final content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );

    if (expand) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: content,
          );
        },
      );
    }

    return content;
  }
}
