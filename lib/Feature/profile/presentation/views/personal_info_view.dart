import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../Auth/ViewModel/auth_cubit.dart';
import '../../../Auth/ViewModel/auth_state.dart';
import '../../widgets/personal_info_avatar.dart';
import '../../widgets/labeled_readonly_field.dart';
import '../../../Auth/widgets/CustomTextField.dart';
import '../../../Auth/widgets/CustomDropdown.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';

class PersonalInfoView extends StatefulWidget {
  const PersonalInfoView({super.key});

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _responsibleController = TextEditingController();

  String? _selectedGender;
  String? _selectedDisabilityType;
  bool _isInitialized = false;

// Keep as stored keys (DB-safe, language-agnostic)
  static const List<String> _genderKeys = ['Male', 'Female'];
  static const List<String> _disabilityKeys = [
    'Visual',
    'Hearing',
    'Physical',
    'Cognitive',
    'Other',
  ];

// Maps stored key → translation key
  static const Map<String, String> _genderTranslationKeys = {
    'Male': 'gender_male',
    'Female': 'gender_female',
  };

  static const Map<String, String> _disabilityTranslationKeys = {
    'Visual': 'disability_visual',
    'Hearing': 'disability_hearing',
    'Physical': 'disability_physical',
    'Cognitive': 'disability_cognitive',
    'Other': 'disability_other',
  };

// Translate a stored key to display label
  String _localizeGender(BuildContext context, String key) =>
      context.tr(_genderTranslationKeys[key] ?? key);

  String _localizeDisability(BuildContext context, String key) =>
      context.tr(_disabilityTranslationKeys[key] ?? key);

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _responsibleController.dispose();
    super.dispose();
  }

  void _fillInitialData(AuthCubit authCubit, AuthState state) {
    final user =
        authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

    if (user != null && !_isInitialized) {
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone;
      _ageController.text = user.age.toString();
      _responsibleController.text = user.responsiblePerson;
      _selectedGender = user.gender;
      _selectedDisabilityType = user.disabilityType;
      _isInitialized = true;
    }
  }

  void _saveChanges(AuthCubit authCubit) {
    if (!_formKey.currentState!.validate()) return;

    final user = authCubit.currentUser;
    if (user == null) return;

    final age = int.tryParse(_ageController.text.trim());
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(context.tr('invalid_age')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    authCubit.updateProfile(
      id: user.id,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      disabilityType: _selectedDisabilityType ?? user.disabilityType,
      responsiblePerson: _responsibleController.text.trim(),
      gender: _selectedGender ?? user.gender,
      age: age,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        centerTitle: true,
        title: Text(
          context.tr('personal_info_title'),
          style: AppTextStyles.subtitle.copyWith(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is UpdateProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text(context.tr('profile_updated')),
                  backgroundColor: Appcolors.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user =
                authCubit.currentUser ?? (state is LoginSuccess ? state.user : null);

            if (user == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              );
            }

            _fillInitialData(authCubit, state);
            final isLoading = state is AuthLoading;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  const PersonalInfoAvatar(),
                  const SizedBox(height: 12),
                  _NameAndMeta(
                    name: _fullNameController.text.isEmpty
                        ? user.fullName
                        : _fullNameController.text,
                    subtitle: user.email,
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _fullNameController,
                    label: context.tr('full_name'),
                    hint: 'John Doe',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('full_name') + ' ' + context.tr('required');
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                  LabeledReadonlyField(
                    label: context.tr('email'),
                    hint: user.email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phoneController,
                    label: context.tr('phone'),
                    hint: '01234567890',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('phone') + "" +context.tr("required") ;
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _ageController,
                    label: context.tr('age'),
                    hint: '25',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('age') + ' ' + context.tr('required');
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return context.tr('invalid_age');
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.cake_outlined),
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: context.tr('gender'),
                    hint: context.tr('select_gender'),
                    // Show localized labels
                    value: _selectedGender != null
                        ? _localizeGender(context, _selectedGender!)
                        : null,
                    items: _genderKeys
                        .map((k) => _localizeGender(context, k))
                        .toList(),
                    onChanged: (localizedValue) {
                      setState(() {
                        // Map localized label back to stored English key
                        _selectedGender = _genderKeys.firstWhere(
                              (k) => _localizeGender(context, k) == localizedValue,
                          orElse: () => localizedValue ?? '',
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _responsibleController,
                    label: context.tr('responsible_person'),
                    hint: context.tr('Name of guardian/responsible person'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.tr('responsible_person') + ' ' + context.tr('required');
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.people_outline),
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: context.tr('disability_type'),
                    hint: context.tr('select_disability_type'),
                    value: _selectedDisabilityType != null
                        ? _localizeDisability(context, _selectedDisabilityType!)
                        : null,
                    items: _disabilityKeys
                        .map((k) => _localizeDisability(context, k))
                        .toList(),
                    onChanged: (localizedValue) {
                      setState(() {
                        _selectedDisabilityType = _disabilityKeys.firstWhere(
                              (k) => _localizeDisability(context, k) == localizedValue,
                          orElse: () => localizedValue ?? '',
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading ? null : () => _saveChanges(authCubit),
                      child: isLoading
                          ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.onPrimary,
                          strokeWidth: 2.4,
                        ),
                      )
                          : Text(
                        context.tr("save_changes"),
                        style: AppTextStyles.button.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NameAndMeta extends StatelessWidget {
  final String name;
  final String subtitle;

  const _NameAndMeta({
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          name,
          style: AppTextStyles.subtitle.copyWith(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}