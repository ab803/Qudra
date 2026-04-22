import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    Color borderColor = theme.dividerColor;
    final enabledBorder = inputTheme.enabledBorder;
    if (enabledBorder is OutlineInputBorder && enabledBorder.borderSide.color != Colors.transparent) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 54,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(color: hintColor),
                ),
                style: theme.textTheme.bodyLarge,
                dropdownColor: theme.cardColor,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: iconColor,
                ),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                )
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