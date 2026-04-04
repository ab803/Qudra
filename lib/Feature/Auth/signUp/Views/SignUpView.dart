import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../ViewModel/auth_cubit.dart';
import '../../ViewModel/auth_state.dart';

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
                _buildTextField(_fullNameController,    'Full Name',               'Enter your full name'),
                _buildTextField(_phoneController,       'Phone Number',            'e.g. 01234567890', type: TextInputType.phone),
                _buildTextField(_emailController,       'Email Address',           'name@example.com',  type: TextInputType.emailAddress),
                _buildTextField(_passwordController,    'Password',                'Min. 8 characters',  obscureText: true),
                _buildTextField(_responsibleController, 'Responsible Person Name', 'Name of guardian'),

                // Age + Gender row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _ageController, 'Age', 'e.g. 25',
                        type: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
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
                _buildDropdown(
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

  // ── Helpers ──────────────────────────────────────

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint, {
        bool obscureText = false,
        TextInputType type = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blueGrey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blueGrey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint,
                    style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 15)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}