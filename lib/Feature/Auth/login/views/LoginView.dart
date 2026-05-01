import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../../core/widgets/adaptive_logo.dart';
import '../../ViewModel/auth_cubit.dart';
import '../../ViewModel/auth_state.dart';
import '../../widgets/AuthActionButton.dart'; // AuthButton
import '../../widgets/CustomTextField.dart';
import '../../widgets/passwordField.dart'; // CustomTextField

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  // This helper converts raw auth failures into friendly user-facing login messages.
  String _buildFriendlyLoginError(BuildContext context, String rawMessage) {
    final message = rawMessage.toLowerCase();

    // This block preserves the institution portal message returned from the auth cubit.
    if (message.contains('institution portal')) {
      return context.tr("institution_portal_login_error");
    }

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('email not confirmed') ||
        message.contains('user not found') ||
        message.contains('invalid email or password')) {
      return context.tr("login_invalid_credentials_error");
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection')) {
      return context.tr("network_error_try_again");
    }

    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return context.tr("too_many_login_attempts");
    }

    return context.tr("login_failed_generic");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go('/home');
        } else if (state is AuthFailure) {
          // This block shows a friendly login error instead of the raw backend message.
          final friendlyMessage =
          _buildFriendlyLoginError(context, state.errorMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(friendlyMessage),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // This block renders the correct logo asset for the active theme.
                  const AdaptiveLogo(width: 140),

                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  Text(
                    context.tr("tagline"),
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Card ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            theme.brightness == Brightness.dark ? 0.18 : 0.03,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr("welcome_back"),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ correct widget name
                        CustomTextField(
                          controller: _emailController,
                          label: context.tr("email_address"),
                          hint: context.tr("email_hint"),
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: theme.inputDecorationTheme.hintStyle?.color,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.tr("email_required");
                            }
                            if (!v.contains('@')) {
                              return context.tr("email_invalid");
                            }
                            return null;
                          },
                        ),

                        // ✅ correct widget name
                        PasswordField(
                          controller: _passwordController,
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forget'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              context.tr("forgot_password_btn"),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ✅ isLoading handled inside AuthButton via BlocBuilder
                        AuthButton(
                          label: context.tr("login"),
                          onPressed: _onLoginPressed,
                          trailingIcon: Icon(
                            Icons.login,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr("no_account")} ',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signUp'),
                        child: Text(
                          context.tr("sign_up"),
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}