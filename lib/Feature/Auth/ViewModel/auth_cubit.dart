import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Services/supabase/AuthService.dart';
import '../../../core/Utilies/getit.dart';
import '../AuhRepo/AuthRepo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IPeopleWithDisabilityRepository _repository;
  final AuthService _authService;

  AuthCubit()
      : _repository = getIt<IPeopleWithDisabilityRepository>(),
        _authService = getIt<AuthService>(),
        super(AuthInitial());

  // ─────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────
  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String disabilityType,
    required String responsiblePerson,
    required String gender,
    required int age,
  }) async {
    emit(AuthLoading());
    try {
      final person = await _repository.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
        disabilityType: disabilityType,
        responsiblePerson: responsiblePerson,
        gender: gender,
        age: age,
      );
      emit(SignUpSuccess(user: person));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.login(email: email, password: password);
      final profile = await _repository.getCurrentProfile();
      if (profile == null) {
        emit(AuthFailure(errorMessage: 'Profile not found'));
        return;
      }
      emit(LoginSuccess(user: profile));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await _authService.forgotPassword(email: email);
      emit(ForgotPasswordSuccess(email: email));
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    emit(AuthLoading());
    try {
      // ✅ goes through repo → service (consistent with the rest of the cubit)
      await _repository.resetPassword(
        email:       email,
        token:       token,
        newPassword: newPassword,
      );
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // RESET STATE
  // ─────────────────────────────────────────
  void reset() => emit(AuthInitial());
}