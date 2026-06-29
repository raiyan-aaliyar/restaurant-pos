import 'package:flutter/material.dart';
import 'package:restobill/core/design/theme/app_design_extension.dart';
import 'package:restobill/core/design/tokens/app_animations.dart';
import 'package:restobill/core/design/tokens/app_component_sizes.dart';
import 'package:restobill/core/design/tokens/app_icon_sizes.dart';
import 'package:restobill/core/design/tokens/app_radius.dart';
import 'package:restobill/core/design/tokens/app_spacing.dart';

/// Minimalist search input with animated focus border and clear action.
///
/// Use for menu search, order lookup, customer search, and filter panels.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChanged() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final design = context.design;
    final colorScheme = Theme.of(context).colorScheme;
    final height = AppComponentSizes.inputHeight(context);

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.standard,
      height: height,
      decoration: BoxDecoration(
        color: design.inputBackground,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: _focused ? design.inputBorderFocused : design.inputBorder,
          width: _focused ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: AnimatedSwitcher(
              duration: AppAnimations.fast,
              child: Icon(
                Icons.search_rounded,
                key: ValueKey(_focused),
                size: AppIconSizes.lg,
                color: _focused
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                isDense: true,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AppAnimations.fast,
            transitionBuilder: AppAnimations.scaleFadeTransition,
            child: _hasText
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: Icon(
                      Icons.close_rounded,
                      size: AppIconSizes.md,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: _clear,
                    tooltip: 'Clear search',
                  )
                : const SizedBox(
                    key: ValueKey('empty'),
                    width: AppSpacing.sm,
                  ),
          ),
        ],
      ),
    );
  }
}
