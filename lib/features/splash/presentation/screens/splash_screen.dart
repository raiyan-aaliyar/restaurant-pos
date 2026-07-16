import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yarpay/features/auth/application/auth_provider.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';
import 'package:yarpay/core/router/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = ref.read(authProvider);
    final restaurant = ref.read(restaurantProvider);

    if (!auth.isAuthenticated) {
      context.go(AppRoutes.login);
      return;
    }

    if (restaurant.isLoading) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    final updatedRestaurant = ref.read(restaurantProvider);

    if (updatedRestaurant.isReady) {
      context.go(AppRoutes.pos);
    } else {
      context.go(AppRoutes.restaurantSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Yarpay',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Restaurant POS',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
