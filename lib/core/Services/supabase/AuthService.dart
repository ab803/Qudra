import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
          email: email, password: password);
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: null, // token sent via email OTP
      );
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD  (verify token + set new password)
  // ─────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      // Step 1: verify the OTP token from the email
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      // Step 2: update to the new password
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Reset password failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────o
  // HELPERS
  // ─────────────────────────────────────────
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => _supabase.auth.currentUser != null;
}