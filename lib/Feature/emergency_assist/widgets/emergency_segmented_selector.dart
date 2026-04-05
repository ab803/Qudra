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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(28),
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
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF0D6EFD)
                        : const Color(0xFF6B7280),
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