import 'package:flutter/material.dart';
import 'CustomTextField.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint = '••••••••',
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        Theme.of(context).inputDecorationTheme.hintStyle?.color ??
            Theme.of(context).iconTheme.color;

    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator ??
              (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
      prefixIcon: Icon(Icons.lock_outline, color: iconColor),
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: iconColor,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}