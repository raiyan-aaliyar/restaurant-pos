import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yarpay/core/config/env.dart';

abstract final class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  static User? get currentUser => auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static Future<void> signOut() async {
    await auth.signOut();
  }
}
