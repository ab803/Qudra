import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
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

    final resolvedLabel =
    widget.label == 'Password' ? context.tr("password") : widget.label;

    final resolvedHint =
    widget.hint == '••••••••' ? context.tr("password_hint") : widget.hint;

    return CustomTextField(
      controller: widget.controller,
      label: resolvedLabel,
      hint: resolvedHint,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator ??
              (v) {
            if (v == null || v.isEmpty) return context.tr("password_required");
            if (v.length < 6) return context.tr("min_6_chars");
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