import 'package:flutter/material.dart';

/// Material 3 bottom navigation bar for mobile layouts.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    (icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale_rounded, label: 'POS'),
    (icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long_rounded, label: 'Orders'),
    (icon: Icons.insights_outlined, selectedIcon: Icons.insights_rounded, label: 'Analytics'),
    (icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.label,
          ),
      ],
    );
  }
}
