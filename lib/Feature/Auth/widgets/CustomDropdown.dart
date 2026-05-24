import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? itemLabelBuilder;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    Color borderColor = theme.dividerColor;
    final enabledBorder = inputTheme.enabledBorder;
    if (enabledBorder is OutlineInputBorder &&
        enabledBorder.borderSide.color != Colors.transparent) {
      borderColor = enabledBorder.borderSide.color;
    }

    final fillColor = inputTheme.fillColor ?? theme.cardColor;
    final hintColor =
        inputTheme.hintStyle?.color ?? theme.textTheme.bodyMedium?.color;
    final textColor = theme.textTheme.bodyLarge?.color;
    final iconColor = theme.iconTheme.color ?? textColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 8),

          // This dropdown now uses DropdownButtonFormField so it can display field-level validation errors.
          DropdownButtonFormField<String>(
            value: value,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: fillColor,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.4,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.4,
                ),
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: iconColor,
            ),
            dropdownColor: theme.cardColor,
            style: theme.textTheme.bodyLarge,
            hint: Text(
              hint,
              style: TextStyle(color: hintColor),
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                value: e,
                child: Text(
                  itemLabelBuilder?.call(e) ?? e,
                  style: TextStyle(color: textColor),
                ),
              ),
            )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}