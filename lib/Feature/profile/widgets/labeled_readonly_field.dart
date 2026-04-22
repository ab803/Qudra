import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class LabeledReadonlyField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final IconData? trailingIcon;
  final TextInputType? keyboardType;

  const LabeledReadonlyField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.trailingIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                prefixIcon,
                color: theme.textTheme.bodyMedium?.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 13.5,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: theme.textTheme.bodyMedium?.color,
                  size: 20,
                ),
            ],
          ),
        ),
      ],
    );
  }
}