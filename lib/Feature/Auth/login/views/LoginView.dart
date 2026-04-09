import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../ViewModel/auth_cubit.dart';
import '../../ViewModel/auth_state.dart';
import '../../widgets/AuthActionButton.dart';   // AuthButton
import '../../widgets/CustomTextField.dart';
import '../../widgets/passwordField.dart';    // CustomTextField

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      email:    _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ));
          context.read<AuthCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ✅ correct widget name
                  Image.asset('assets/images/Qudra logo.png', width: 140),
                  const SizedBox(height: 24),

                  const SizedBox(height: 8),
                  Text(
                    '"With you to discover your ability"',
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey.shade600),
                  ),
                  const SizedBox(height: 40),

                  // ── Card ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // ✅ correct widget name
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.mail_outline,
                              color: Colors.grey.shade600),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Email is required';
                            if (!v.contains('@'))
                              return 'Enter a valid email';
                            return null;
                          },
                        ),

                        // ✅ correct widget name
                        PasswordField(controller: _passwordController,),

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
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Appcolors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ isLoading handled inside AuthButton via BlocBuilder
                        AuthButton(
                          label: 'Login',
                          onPressed: _onLoginPressed,
                          trailingIcon: const Icon(Icons.login,
                              color: Colors.white, size: 20),
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
                            color: Colors.blueGrey.shade600, fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signUp'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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