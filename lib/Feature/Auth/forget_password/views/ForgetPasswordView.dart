  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:go_router/go_router.dart';
  import '../../ViewModel/auth_cubit.dart';
  import '../../ViewModel/auth_state.dart';
  import '../../widgets/CustomTextField.dart';


  class ForgotPasswordView extends StatefulWidget {
    const ForgotPasswordView({super.key});

    @override
    State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
  }

  class _ForgotPasswordViewState extends State<ForgotPasswordView> {
    final _emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    @override
    void dispose() {
      _emailController.dispose();
      super.dispose();
    }

    void _onResetPressed() {
      if (!_formKey.currentState!.validate()) return;
      context.read<AuthCubit>().forgotPassword(
        email: _emailController.text.trim(),
      );
    }

    @override
    Widget build(BuildContext context) {
      return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            // ✅ Pass email to ResetPasswordView via GoRouter extra
            context.go('/resetPassword', extra: state.email);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<AuthCubit>().reset();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/login'),
            ),
            title: const Text(
              'Forgot Password',
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey.shade200, height: 1.0),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.restore_page_outlined,
                          color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Reset your\npassword',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter the email address associated with your account. We\'ll send you a secure link to reset your password.',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                          height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Email Address',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                        controller:_emailController,
                        label:'Email Address',hint:'name@example.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 8),
                    Text(
                      'Make sure this is the email you signed up with.',
                      style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 48),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onResetPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                                : const Text('Reset Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: InkWell(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Remember your password? ',
                            style:
                            TextStyle(color: Color(0xFF374151), fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }