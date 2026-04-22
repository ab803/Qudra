import 'package:flutter/material.dart';

import '../../../core/Styles/AppColors.dart';


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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final bg = selected
        ? color.withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.10)
        : theme.cardColor;
    final border =
    selected ? color.withOpacity(0.40) : theme.dividerColor;
    final fg = selected ? color : onSurface.withOpacity(0.72);

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
            Icon(
              icon,
              size: 18,
              color: fg,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
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
