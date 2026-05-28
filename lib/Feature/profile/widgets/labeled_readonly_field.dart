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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.dividerColor),
                ),
                alignment: Alignment.center,
                child: Icon(
                  prefixIcon,
                  color: theme.textTheme.bodyMedium?.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    hint,
                    style: AppTextStyles.body.copyWith(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    trailingIcon,
                    color: theme.textTheme.bodyMedium?.color,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
