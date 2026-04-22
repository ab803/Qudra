import 'package:flutter/material.dart';

class EmergencyQuickNeedsWrap extends StatelessWidget {
  const EmergencyQuickNeedsWrap({
    super.key,
    required this.quickNeeds,
    required this.selectedQuickNeeds,
    required this.onToggle,
  });

  final List<String> quickNeeds;
  final Set<String> selectedQuickNeeds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'احتياجات سريعة',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: quickNeeds.map((label) {
            final isSelected = selectedQuickNeeds.contains(label);
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onToggle(label),
              selectedColor: colorScheme.primary.withOpacity(
                theme.brightness == Brightness.dark ? 0.16 : 0.10,
              ),
              checkmarkColor: colorScheme.primary,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.72),
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : theme.dividerColor,
              ),
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}
