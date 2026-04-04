import 'package:flutter/cupertino.dart';
import '../../../core/Models/people_with_disabilityModel.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SignUpSuccess extends AuthState {
  final PeopleWithDisabilityModel user;
  SignUpSuccess({required this.user});
}

class LoginSuccess extends AuthState {
  final PeopleWithDisabilityModel user;
  LoginSuccess({required this.user});
}

class ForgotPasswordSuccess extends AuthState {
  final String email;
  ForgotPasswordSuccess({required this.email});
}

// ✅ New state — password was reset successfully
class ResetPasswordSuccess extends AuthState {}

class LogoutSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String errorMessage;
  AuthFailure({required this.errorMessage});
}