import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  String _buildFriendlyLoginError(String rawMessage) {
    final message = rawMessage.toLowerCase();

    // This block preserves the institution portal message returned from the auth cubit.
    if (message.contains('institution portal')) {
      return 'This account belongs to the institution portal. Please use the institution app instead.';
    }

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('email not confirmed') ||
        message.contains('user not found') ||
        message.contains('invalid email or password')) {
      return 'This email is not registered or the password is incorrect. Please check your details or create a new account first.';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection')) {
      return 'Unable to connect right now. Please check your internet connection and try again.';
    }

    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Too many login attempts. Please wait a moment and try again.';
    }

    return 'Login failed. Please try again.';
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
          final friendlyMessage = _buildFriendlyLoginError(state.errorMessage);
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
                    '"With you to discover your ability"',
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
                          'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // ✅ correct widget name
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.mail_outline,
                            color: theme.inputDecorationTheme.hintStyle?.color,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Enter a valid email';
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
                              'Forgot Password?',
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
                          label: 'Login',
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
                        "Don't have an account? ",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signUp'),
                        child: Text(
                          'Sign Up',
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
