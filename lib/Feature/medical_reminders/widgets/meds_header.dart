import 'package:flutter/material.dart';

// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';

class MedsHeader extends StatelessWidget {
  const MedsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),

        // This block renders the upgraded Care Plans title.
        Text(
          context.tr('care_plans'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 30,
            color: colorScheme.primary,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        // This block explains that Care Plans combine medication, feeding, rehab, and learning goals.
        Text(
          context.tr('care_plans_subtitle'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.68),
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 14),

        // This block shows quick visual category chips to make the new scope obvious.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeaderCategoryChip(
              icon: Icons.medication_outlined,
              label: context.tr('plan_type_medication'),
              color: const Color(0xFF22C55E),
            ),
            _HeaderCategoryChip(
              icon: Icons.restaurant_outlined,
              label: context.tr('plan_type_feeding'),
              color: const Color(0xFFF97316),
            ),
            _HeaderCategoryChip(
              icon: Icons.fitness_center_outlined,
              label: context.tr('plan_type_rehab'),
              color: const Color(0xFF3B82F6),
            ),
            _HeaderCategoryChip(
              icon: Icons.school_outlined,
              label: context.tr('plan_type_learning'),
              color: const Color(0xFFA855F7),
            ),
          ],
        ),
      ],
    );
  }
}

// This widget renders a small category chip in the Care Plans header.
class _HeaderCategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeaderCategoryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(
          theme.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // This icon visually identifies the Care Plan category.
          Icon(
            icon,
            size: 14,
            color: color,
          ),

          const SizedBox(width: 6),

          // This text shows the localized category label.
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}