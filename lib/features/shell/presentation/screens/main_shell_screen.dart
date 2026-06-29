import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restobill/core/utils/responsive.dart';
import 'package:restobill/features/shell/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:restobill/features/shell/presentation/widgets/app_navigation_rail.dart';

/// Root shell hosting bottom navigation (mobile) or navigation rail (tablet+).
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final useRail = Responsive.useNavigationRail(context);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            AppNavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              extended: Responsive.isLargeTablet(context),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
