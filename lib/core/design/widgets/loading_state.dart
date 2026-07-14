import 'package:flutter/material.dart';
import 'package:yarpay/core/design/theme/app_design_extension.dart';
import 'package:yarpay/core/design/tokens/app_animations.dart';
import 'package:yarpay/core/design/tokens/app_radius.dart';
import 'package:yarpay/core/design/tokens/app_spacing.dart';

/// Loading indicator with optional shimmer skeleton placeholders.
///
/// Use while fetching orders, menu data, or analytics — before real content
/// is available.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.showSkeleton = false,
    this.skeletonCount = 3,
  });

  final String? message;
  final bool showSkeleton;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedSwitcher(
        duration: AppAnimations.normal,
        child: showSkeleton
            ? _SkeletonList(count: skeletonCount)
            : Column(
                key: const ValueKey('spinner'),
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: ValueKey('skeleton_$count'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _ShimmerBox(
        height: index == 0 ? 64 : 48,
        borderRadius: AppRadius.radiusMd,
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.height,
    required this.borderRadius,
  });

  final double height;
  final BorderRadius borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slower,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final design = context.design;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: [
                design.shimmerBase,
                design.shimmerHighlight,
                design.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
