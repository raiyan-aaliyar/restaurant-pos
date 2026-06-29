import 'package:flutter/material.dart';
import 'package:restobill/core/constants/app_constants.dart';
import 'package:restobill/core/utils/responsive.dart';
import 'package:restobill/core/widgets/animated_theme_toggle.dart';

/// Shared scaffold with app bar, theme toggle, and responsive content padding.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final screenType = Responsive.screenTypeOf(context);
    final padding = Responsive.screenPadding(screenType);
    final maxWidth = Responsive.contentMaxWidth(screenType);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: AnimatedThemeToggle(),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: padding,
                  child: body,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
