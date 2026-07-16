import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/data/services/supabase_service.dart';
import 'package:yarpay/features/auth/application/auth_provider.dart';
import 'package:yarpay/features/restaurant/domain/restaurant.dart';

class RestaurantState {
  final Restaurant? restaurant;
  final UserProfile? userProfile;
  final bool isLoading;
  final String? error;

  const RestaurantState({
    this.restaurant,
    this.userProfile,
    this.isLoading = false,
    this.error,
  });

  bool get hasRestaurant => restaurant != null;
  bool get hasProfile => userProfile != null;
  bool get isReady => hasRestaurant && hasProfile;

  RestaurantState copyWith({
    Restaurant? restaurant,
    UserProfile? userProfile,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RestaurantState(
      restaurant: restaurant ?? this.restaurant,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RestaurantNotifier extends Notifier<RestaurantState> {
  @override
  RestaurantState build() {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      final userId = authState.user!.id;
      _loadUserProfile(userId);
    } else {
      return const RestaurantState();
    }

    return const RestaurantState(isLoading: true);
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await SupabaseService.client.rpc('get_my_profile');

      if (response == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final profileData = response['profile'] as Map<String, dynamic>?;
      final restaurantData = response['restaurant'] as Map<String, dynamic>?;

      if (profileData == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final profile = UserProfile.fromJson(profileData);
      final restaurant =
          restaurantData != null ? Restaurant.fromJson(restaurantData) : null;

      state = state.copyWith(
        userProfile: profile,
        restaurant: restaurant,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> createRestaurant({
    required String name,
    required String address,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = SupabaseService.auth.currentSession;
      final userId = SupabaseService.currentUserId;

      if (userId == null || session == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Not authenticated. Please log out and log in again.',
        );
        return false;
      }

      final response = await SupabaseService.client
          .rpc('create_restaurant_with_profile', params: {
        'p_name': name,
        'p_address': address,
        'p_phone': phone,
      });

      final restaurantData = response['restaurant'] as Map<String, dynamic>;
      final profileData = response['profile'] as Map<String, dynamic>;

      final restaurant = Restaurant.fromJson(restaurantData);
      final profile = UserProfile.fromJson(profileData);

      state = state.copyWith(
        restaurant: restaurant,
        userProfile: profile,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create restaurant.',
      );
      return false;
    }
  }

  Future<void> refresh() async {
    final userId = SupabaseService.currentUserId;
    if (userId != null) {
      state = state.copyWith(isLoading: true);
      await _loadUserProfile(userId);
    }
  }
}

final restaurantProvider =
    NotifierProvider<RestaurantNotifier, RestaurantState>(
  RestaurantNotifier.new,
);

final restaurantIdProvider = Provider<String?>((ref) {
  final restaurantState = ref.watch(restaurantProvider);
  return restaurantState.restaurant?.id;
});
