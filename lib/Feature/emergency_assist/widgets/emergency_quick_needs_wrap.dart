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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'احتياجات سريعة',
          style: TextStyle(
            color: Color(0xFF111827),
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
              selectedColor: const Color(0xFFEAF2FF),
              checkmarkColor: const Color(0xFF0D6EFD),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF0D6EFD)
                    : const Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF0D6EFD)
                    : const Color(0xFFE5E7EB),
              ),
              backgroundColor: Colors.white,
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