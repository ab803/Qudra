import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../ViewModel/auth_cubit.dart';
import '../../ViewModel/auth_state.dart';
import '../../widgets/CustomDropdown.dart';
import '../../widgets/CustomTextField.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // ── Controllers ──────────────────────────────────
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _disabilityController = TextEditingController();
  final _responsibleController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedDisabilityType;

  // English API values — never change these regardless of locale.
  static const List<String> _genderApiValues = ['Male', 'Female'];
  static const List<String> _disabilityApiValues = [
    'Visual',
    'Hearing',
    'Physical',
    'Cognitive',
    'Other',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _disabilityController.dispose();
    _responsibleController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────

  /// Maps a translated display label back to its English API value.
  String _toApiGender(String display) {
    final displayOptions = _genderDisplayOptions(context);
    final idx = displayOptions.indexOf(display);
    return idx >= 0 ? _genderApiValues[idx] : display;
  }

  String _toApiDisability(String display) {
    final displayOptions = _disabilityDisplayOptions(context);
    final idx = displayOptions.indexOf(display);
    return idx >= 0 ? _disabilityApiValues[idx] : display;
  }

  List<String> _genderDisplayOptions(BuildContext ctx) => [
    ctx.tr('gender_male'),
    ctx.tr('gender_female'),
  ];

  List<String> _disabilityDisplayOptions(BuildContext ctx) => [
    ctx.tr('category_visual'),
    ctx.tr('category_hearing'),
    ctx.tr('category_physical'),
    ctx.tr('category_cognitive'),
    ctx.tr('category_other'),
  ];

  // ── Submit ───────────────────────────────────────
  void _onSignUp(BuildContext context) {
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _ageController.text.trim().isEmpty ||
        _responsibleController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedDisabilityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('fill_all_fields')),
          backgroundColor: Appcolors.EmergancyColor,
        ),
      );
      return;
    }

    context.read<AuthCubit>().signUp(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      disabilityType: _toApiDisability(_selectedDisabilityType!),
      responsiblePerson: _responsibleController.text.trim(),
      gender: _toApiGender(_selectedGender!),
      age: int.parse(_ageController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final genderOptions = _genderDisplayOptions(context);
    final disabilityOptions = _disabilityDisplayOptions(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('account_created')),
              backgroundColor: Appcolors.successColor,
            ),
          );
          context.go('/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          debugPrint('SignUp Error: ${state.errorMessage}');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.appBarTheme.foregroundColor,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              context.tr('sign_up'),
              style: TextStyle(
                color: theme.appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr('create_account'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('join_qudra'),
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── Fields ──────────────────────────
                CustomTextField(
                  controller: _fullNameController,
                  label: context.tr('full_name'),
                  hint: context.tr('full_name_hint'),
                  keyboardType: TextInputType.name,
                ),
                CustomTextField(
                  controller: _phoneController,
                  label: context.tr('phone_number'),
                  hint: context.tr('phone_hint'),
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  controller: _emailController,
                  label: context.tr('email_address'),
                  hint: context.tr('email_hint'),
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: context.tr('password'),
                  hint: context.tr('password_hint'),
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                CustomTextField(
                  controller: _responsibleController,
                  label: context.tr('responsible_person'),
                  hint: context.tr('responsible_hint'),
                  keyboardType: TextInputType.name,
                ),

                // Age + Gender row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _ageController,
                        label: context.tr('age'),
                        hint: context.tr('age_hint'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown(
                        label: context.tr('gender'),
                        hint: context.tr('select'),
                        value: _selectedGender,
                        items: genderOptions,
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                    ),
                  ],
                ),

                CustomDropdown(
                  label: context.tr('disability_type_label'),
                  hint: context.tr('select_type'),
                  value: _selectedDisabilityType,
                  items: disabilityOptions,
                  onChanged: (val) =>
                      setState(() => _selectedDisabilityType = val),
                ),

                const SizedBox(height: 16),

                // ── Sign Up Button ───────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : () => _onSignUp(context),
                    child: isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.tr('sign_up'),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Login Prompt ─────────────────────
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: '${context.tr('already_have_account')} ',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: context.tr('log_in'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}