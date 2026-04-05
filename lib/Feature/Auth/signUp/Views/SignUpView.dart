  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:go_router/go_router.dart';
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
    final _fullNameController    = TextEditingController();
    final _phoneController       = TextEditingController();
    final _emailController       = TextEditingController();
    final _passwordController    = TextEditingController();
    final _disabilityController  = TextEditingController();
    final _responsibleController = TextEditingController();
    final _ageController         = TextEditingController();
  
    String? _selectedGender;
    String? _selectedDisabilityType;
  
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
      _emailController.dispose();
      _passwordController.dispose();
      _disabilityController.dispose();
      _responsibleController.dispose();
      _ageController.dispose();
      super.dispose();
    }
  
    // ── Submit ───────────────────────────────────────
    void _onSignUp(BuildContext context) {
      // Basic validation
      if (_fullNameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _ageController.text.trim().isEmpty ||
          _responsibleController.text.trim().isEmpty ||
          _selectedGender == null ||
          _selectedDisabilityType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
  
      context.read<AuthCubit>().signUp(
        fullName:          _fullNameController.text.trim(),
        phone:             _phoneController.text.trim(),
        email:             _emailController.text.trim(),
        password:          _passwordController.text.trim(),
        disabilityType:    _selectedDisabilityType!,
        responsiblePerson: _responsibleController.text.trim(),
        gender:            _selectedGender!,
        age:               int.parse(_ageController.text.trim()),
      );
    }
  
    @override
    Widget build(BuildContext context) {
      return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home'); // ← your home route
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("problem : it is a problem in registration "),
                backgroundColor: Colors.red,
              ),
            );
            print(state.errorMessage);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
  
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join Qudra to access tailored services',
                    style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
  
                  // ── Fields ──────────────────────────
                  CustomTextField(controller: _fullNameController,label:'Full Name',hint:'Enter your full name', keyboardType: TextInputType.name,),
                  CustomTextField(controller:_phoneController,label:  'Phone Number',hint:'e.g. 01234567890', keyboardType: TextInputType.phone),
                  CustomTextField(controller:_emailController,label:'Email Address',hint:'name@example.com',  keyboardType: TextInputType.emailAddress),
                  CustomTextField(controller:_passwordController,label: 'Password',hint:'Min. 8 characters',  obscureText: true, keyboardType:TextInputType.visiblePassword ,),
                  CustomTextField(controller:_responsibleController,label: 'Responsible Person Name', hint:'Name of guardian', keyboardType: TextInputType.name,),
  
                  // Age + Gender row
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _ageController,
                          label: 'Age',
                          hint:'e.g. 25',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomDropdown(
                          label:   'Gender',
                          hint:    'Select',
                          value:   _selectedGender,
                          items:   _genderOptions,
                          onChanged: (val) => setState(() => _selectedGender = val),
                        ),
                      ),
                    ],
                  ),
  
                  // Disability Type dropdown
                  CustomDropdown(
                    label:    'Disability Type',
                    hint:     'Select your type',
                    value:    _selectedDisabilityType,
                    items:    _disabilityOptions,
                    onChanged: (val) => setState(() => _selectedDisabilityType = val),
                  ),
  
                  const SizedBox(height: 16),
  
                  // ── Sign Up Button ───────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : () => _onSignUp(context),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // ── Login Prompt ─────────────────────
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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