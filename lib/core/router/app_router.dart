import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yarpay/core/router/app_routes.dart';
import 'package:yarpay/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:yarpay/features/auth/application/auth_provider.dart';
import 'package:yarpay/features/auth/presentation/screens/login_screen.dart';
import 'package:yarpay/features/auth/presentation/screens/signup_screen.dart';
import 'package:yarpay/features/orders/presentation/screens/orders_screen.dart';
import 'package:yarpay/features/pos/presentation/screens/pos_screen.dart';
import 'package:yarpay/features/restaurant/presentation/screens/restaurant_setup_screen.dart';
import 'package:yarpay/features/settings/presentation/screens/settings_screen.dart';
import 'package:yarpay/features/shell/presentation/screens/main_shell_screen.dart';
import 'package:yarpay/features/splash/presentation/screens/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.restaurantSetup;

      if (!auth.isAuthenticated && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.restaurantSetup,
        builder: (context, state) => const RestaurantSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pos,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PosScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: OrdersScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AnalyticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
