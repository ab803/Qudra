import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
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
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          // ✅ Pass email to ResetPasswordView via GoRouter extra
          context.go('/resetPassword', extra: state.email);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () => context.go('/login'),
          ),
          title: Text(
            context.tr("forgot_password_title"),
            style: TextStyle(
              color: theme.appBarTheme.foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.dividerColor,
              height: 1.0,
            ),
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
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.restore_page_outlined,
                      color: theme.colorScheme.onPrimary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.tr("reset_password_heading"),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr("reset_password_desc"),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _emailController,
                    label: context.tr("email_address"),
                    hint: context.tr("email_hint"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr("email_note"),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            context.tr("reset_password_btn"),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: InkWell(
                      onTap: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          text: '${context.tr("remember_password")} ',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: context.tr("sign_in"),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
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