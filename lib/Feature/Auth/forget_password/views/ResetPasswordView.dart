import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../ViewModel/auth_cubit.dart';
import '../../ViewModel/auth_state.dart';
import '../../widgets/CustomTextField.dart';
import '../../../../core/Styles/AppColors.dart';

class ResetPasswordView extends StatefulWidget {
  // ✅ email is passed as a route parameter from ForgotPasswordView
  final String email;
  const ResetPasswordView({super.key, required this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().resetPassword(
      email: widget.email,
      token: _tokenController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr("password_updated")),
              backgroundColor: Appcolors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // This block navigates to the login screen after a successful password reset.
          context.go('/login');
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
            // This block always returns the user to the forgot password screen.
            onPressed: () => context.go('/forget'),
          ),
          title: Text(
            context.tr("reset_password_title"),
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
        // ✅ Button pinned to bottom, form scrolls above it
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Instruction ────────────────────────────
                        Text(
                          context.tr("reset_password_instruction"),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Verification Token ─────────────────────
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _tokenController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.tr("token_required");
                            }
                            return null;
                          },
                          label: context.tr("verification_token"),
                          hint: context.tr("token_hint"),
                        ),
                        const SizedBox(height: 24),

                        // ── New Password ───────────────────────────
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.tr("password_required");
                            }
                            if (v.length < 6) {
                              return context.tr("min_6_chars");
                            }
                            return null;
                          },
                          label: context.tr("new_password"),
                          hint: context.tr("new_password_hint"),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 24),

                        // ── Confirm Password ───────────────────────
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return context.tr("confirm_password_required");
                            }
                            if (v != _passwordController.text) {
                              return context.tr("passwords_no_match");
                            }
                            return null;
                          },
                          label: context.tr("confirm_password"),
                          hint: context.tr("confirm_password_hint"),
                          keyboardType: TextInputType.visiblePassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Update Password Button (pinned to bottom) ────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onUpdatePressed,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
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
                          context.tr("update_password"),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}