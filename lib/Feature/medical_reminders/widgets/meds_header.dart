import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';

class MedsHeader extends StatelessWidget {
  const MedsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              // This header title is localized for the medical reminders screen.
              context.tr('medical_reminders'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 28,
                color: theme.colorScheme.primary,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}