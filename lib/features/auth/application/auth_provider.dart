import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yarpay/data/services/supabase_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? message;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.message,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    String? message,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AuthState build() {
    final currentUser = SupabaseService.currentUser;
    final initialState = AuthState(user: currentUser);

    _authSubscription = SupabaseService.auth.onAuthStateChange.map((data) {
      final sessionUser = data.session?.user;
      return AuthState(user: sessionUser);
    }).listen((newState) {
      state = newState;
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return initialState;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearMessage: true);

    try {
      final response = await SupabaseService.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        if (response.session != null) {
          state = state.copyWith(
            user: response.user,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            user: response.user,
            isLoading: false,
            message: 'Check your email for a confirmation link.',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Signup failed. Please try again.',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearMessage: true);

    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        state = state.copyWith(
          user: response.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await SupabaseService.signOut();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
