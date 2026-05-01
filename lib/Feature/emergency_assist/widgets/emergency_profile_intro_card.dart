import 'package:flutter/material.dart';

import '../../../core/Services/Localization/translation_extension.dart';
// This importServices/Localization/translation_extension.dart';// This import enables localized text access using context.tr().

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
                  // This intro title is localized for the emergency profile setup card.
                  context.tr('emergency_profile_intro_title'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // This intro subtitle is localized for the emergency profile setup card.
                  context.tr('emergency_profile_intro_subtitle'),
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

