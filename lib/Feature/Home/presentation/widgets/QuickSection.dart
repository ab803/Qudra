import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';
import 'package:go_router/go_router.dart';

import 'Quick_access_card.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Quick Access',
          style: AppTextStyles.title.copyWith(
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),

        // Emergency card
        GestureDetector(
          onTap: () => context.push('/emergency-entry'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withOpacity(
                    theme.brightness == Brightness.dark ? 0.22 : 0.30,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emergency icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                // Text info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('emergency_call'),
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('emergency_subtitle'),
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Two quick cards row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // GoRouter
                  context.push('/chat'); // أو context.go('/chat') حسب اللي تحبه
                },
                child: QuickAccessCard(
                  title: context.tr('intelligent'),
                  subtitle: context.tr('assistant'),
                  icon: Symbols.robot_2,
                  color: Appcolors.cardTeal,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // GoRouter
                  context.push('/reminders'); //
                },
                child: QuickAccessCard(
                  title: context.tr('medical'),
                  subtitle: context.tr('reminders'),
                  icon: Icons.medication,
                  color: Appcolors.cardGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Accessibility card
        GestureDetector(
          onTap: () => context.push('/accessibility'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Appcolors.rateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book, color: Appcolors.rateColor),
                ),
                const SizedBox(width: 16),

                // Text info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('accessibility'),
                      style: AppTextStyles.subtitle.copyWith(
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      context.tr('guidelines'),
                      style: AppTextStyles.body.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('learn_rights'),
                      style: AppTextStyles.body.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}