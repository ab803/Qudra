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

  // This helper returns the institution portal warning used across auth flows.
  String get _institutionPortalMessage =>
      'This account belongs to the institution portal. Please use the institution app instead.';

  // This helper returns the user app missing-profile warning after login.
  String get _missingUserProfileMessage =>
      'This account is not registered in the user app. Please sign up first.';

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
        return;
      }

      // This block signs out persisted institution sessions to prevent entering the user app with invalid profile data.
      final authUserId = _authService.currentUser?.id;
      if (authUserId != null) {
        final isInstitutionAccount =
        await _authService.isInstitutionAccountById(authUserId);
        if (isInstitutionAccount) {
          await _authService.logout();
        }
      }

      currentUser = null;
      emit(AuthInitial());
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
      // This block prevents creating a user app account with an email that already belongs to a user app profile.
      final isUserEmailRegistered = await _repository.isEmailRegistered(email);
      if (isUserEmailRegistered) {
        emit(
          AuthFailure(
            errorMessage:
            'This email is already registered. Please log in instead.',
          ),
        );
        return;
      }

      // This block prevents creating a user app account with an email that already belongs to an institution account.
      final isInstitutionEmailRegistered =
      await _authService.isInstitutionEmailRegistered(email);
      if (isInstitutionEmailRegistered) {
        emit(
          AuthFailure(
            errorMessage:
            'This email is already registered as an institution account. Please use the institution app instead.',
          ),
        );
        return;
      }

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

  Future<void> updateProfile({
    required String id,
    required String fullName,
    required String phone,
    required String disabilityType,
    required String responsiblePerson,
    required String gender,
    required int age,
  }) async {
    emit(AuthLoading());

    try {
      await _repository.updateProfile(
        id: id,
        fullName: fullName,
        phone: phone,
        disabilityType: disabilityType,
        responsiblePerson: responsiblePerson,
        gender: gender,
        age: age,
      );

      final updatedProfile = await _repository.getCurrentProfile();
      if (updatedProfile == null) {
        emit(AuthFailure(errorMessage: 'Profile not found after update'));
        return;
      }

      currentUser = updatedProfile;
      emit(UpdateProfileSuccess(user: updatedProfile));
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
      if (profile != null) {
        currentUser = profile; // ✅ خزّن المستخدم
        emit(LoginSuccess(user: profile));
        return;
      }

      // This block detects institution accounts after a successful auth login and prevents them from entering the user app.
      final authUserId = _authService.currentUser?.id;
      if (authUserId != null) {
        final isInstitutionAccount =
        await _authService.isInstitutionAccountById(authUserId);

        if (isInstitutionAccount) {
          await _authService.logout();
          currentUser = null;
          emit(AuthFailure(errorMessage: _institutionPortalMessage));
          return;
        }
      }

      await _authService.logout();
      currentUser = null;
      emit(AuthFailure(errorMessage: _missingUserProfileMessage));
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