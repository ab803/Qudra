import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class A11ySegmentFilter extends StatelessWidget {
  const A11ySegmentFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _SegmentPill(
          label: 'Visual',
          icon: Icons.visibility_outlined,
          selected: true,
          color: Appcolors.cardBlue,
        ),
        SizedBox(width: 8),
        _SegmentPill(
          label: 'Hearing',
          icon: Icons.hearing_outlined,
          selected: false,
          color: Appcolors.cardPurple,
        ),
        SizedBox(width: 8),
        _SegmentPill(
          label: 'Physical',
          icon: Icons.accessibility_new_outlined,
          selected: false,
          color: Appcolors.cardOrange,
        ),
      ],
    );
  }
}

class _SegmentPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  const _SegmentPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : Appcolors.backgroundColor;
    final border = selected ? color.withOpacity(0.35) : Colors.grey.shade200;
    final fg = selected ? Appcolors.primaryColor : Appcolors.primaryColor;

    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Appcolors.textLight),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}