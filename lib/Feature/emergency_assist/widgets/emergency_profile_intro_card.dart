import 'package:flutter/material.dart';

class EmergencyProfileIntroCard extends StatelessWidget {
  const EmergencyProfileIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(
                theme.brightness == Brightness.dark ? 0.16 : 0.08,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.badge_outlined,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلوماتك\nالمنقذة للحياة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هذه البيانات تساعد فرق الطوارئ أو مقدم الدعم المناسب للوصول إليك بسرعة وقت الحاجة.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.72),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}