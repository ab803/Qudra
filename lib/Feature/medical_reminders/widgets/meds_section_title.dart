import 'package:flutter/material.dart';

class MedsSectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;

  const MedsSectionTitle({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}