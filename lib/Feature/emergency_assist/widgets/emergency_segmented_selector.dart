import 'package:flutter/material.dart';

class EmergencySegmentedOption<T> {
  const EmergencySegmentedOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class EmergencySegmentedSelector<T> extends StatelessWidget {
  const EmergencySegmentedSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<EmergencySegmentedOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.16 : 0.10,
                  )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(
                        theme.brightness == Brightness.dark
                            ? 0.08
                            : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.68),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}