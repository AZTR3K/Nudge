import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. A stream that listens to whether the user is logged in or logged out
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// 2. The provider that holds our login/register functions
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

class AuthService {
  final SupabaseClient _supabase;
  AuthService(this._supabase);

  Future<void> signIn(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String fullName) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName}, // Saves their name in the user metadata
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
