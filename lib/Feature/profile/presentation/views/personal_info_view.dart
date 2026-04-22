import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  static const List<String> _genderOptions = ['Male', 'Female'];
  static const List<String> _disabilityOptions = [
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
          content: const Text('Please enter a valid age'),
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
          'Personal Info',
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
                const SnackBar(
                  content: Text('Profile updated successfully'),
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
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 12),
                  LabeledReadonlyField(
                    label: 'Email Address',
                    hint: user.email,
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'e.g. 01234567890',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _ageController,
                    label: 'Age',
                    hint: 'e.g. 25',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Age is required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.cake_outlined),
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: 'Gender',
                    hint: 'Select gender',
                    value: _selectedGender,
                    items: _genderOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _responsibleController,
                    label: 'Responsible Person',
                    hint: 'Name of guardian/responsible person',
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Responsible person is required';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.people_outline),
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown(
                    label: 'Disability Type',
                    hint: 'Select disability type',
                    value: _selectedDisabilityType,
                    items: _disabilityOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedDisabilityType = value;
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
                        'Save Changes',
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