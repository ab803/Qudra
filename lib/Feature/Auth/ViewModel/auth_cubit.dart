import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/Models/people_with_disabilityModel.dart';
import '../../../core/Services/supabase/AuthService.dart';
import '../../../core/Utilies/getit.dart';
import '../AuhRepo/AuthRepo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IPeopleWithDisabilityRepository _repository;
  final AuthService _authService;

  // ✅ هنخزن المستخدم الحالي هنا
  PeopleWithDisabilityModel? currentUser;

  AuthCubit()
      : _repository = getIt<IPeopleWithDisabilityRepository>(),
        _authService = getIt<AuthService>(),
        super(AuthInitial());

  // ─────────────────────────────────────────
  // LOAD CURRENT USER ON APP START
  // ─────────────────────────────────────────
  Future<void> loadCurrentUser() async {
    try {
      emit(AuthRestoring());
      final profile = await _repository.getCurrentProfile();

      if (profile != null) {
        currentUser = profile;
        emit(LoginSuccess(user: profile));
      } else {
        currentUser = null;
        emit(AuthInitial());
      }
    } catch (e) {
      currentUser = null;
      emit(AuthFailure(errorMessage: e.toString()));
    }
  }

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

      currentUser = person; // ✅ خزّن المستخدم
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

      currentUser = profile; // ✅ خزّن المستخدم
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
      await _repository.resetPassword(
        email: email,
        token: token,
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
      currentUser = null; // ✅ فضّي المستخدم عند logout
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