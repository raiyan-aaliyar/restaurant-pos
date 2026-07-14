import 'package:flutter/material.dart';
import 'package:yarpay/core/constants/app_constants.dart';

/// Material 3 navigation rail for tablet and large tablet layouts.
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  static const _destinations = [
    (icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale_rounded, label: 'POS'),
    (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Orders'),
    (icon: Icons.insights_outlined, selectedIcon: Icons.insights_rounded, label: 'Analytics'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      leading: extended
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Icon(
                Icons.restaurant_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
      destinations: [
        for (final destination in _destinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
