import 'package:flutter/material.dart';

class EmergencyLabeledField extends StatelessWidget {
  const EmergencyLabeledField({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
    this.isRequired = false,
    this.spacing = 10,
  });

  final String label;
  final Widget child;
  final String? errorText;
  final bool isRequired;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: spacing),
        child,
        if (errorText != null && errorText!.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}