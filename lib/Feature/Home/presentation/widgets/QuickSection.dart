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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // This block localizes the AI card naming while keeping the original quick card style.
    final aiCardTitle = isArabic ? 'قدرة AI' : 'Qudra AI';
    final aiCardSubtitle = isArabic ? 'مساعد' : 'Assistant';

    // This block introduces Care Plans as the upgraded medical reminders entry point.
    final carePlansTitle = isArabic ? 'الرعاية' : 'Care';
    final carePlansSubtitle = isArabic ? 'أهداف' : 'Plans';

    // This block introduces Smart Accessible Map as a quick access entry point.
    final smartMapTitle = isArabic ? 'الخريطة' : 'Map';
    final smartMapSubtitle = isArabic ? 'قريب' : 'Nearby';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This block renders the Quick Access section title.
        Text(
          context.tr("quick_access"),
          style: AppTextStyles.title.copyWith(
            color: theme.textTheme.titleLarge?.color,
          ),
        ),

        const SizedBox(height: 16),

        // This block renders the emergency access card.
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
                // This block renders the emergency icon.
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

                // This block renders the emergency title and subtitle.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr("emergency_call"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr("emergency_subtitle"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // This block renders the navigation arrow for the emergency card.
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

        // This block renders Qudra AI, Care Plans, and Smart Map in one horizontal row using the same QuickAccessCard style.
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push('/chat');
                },
                child: QuickAccessCard(
                  title: aiCardTitle,
                  subtitle: aiCardSubtitle,
                  icon: Symbols.robot_2,
                  color: Appcolors.cardTeal,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push('/reminders');
                },
                child: QuickAccessCard(
                  title: carePlansTitle,
                  subtitle: carePlansSubtitle,
                  icon: Icons.event_available_rounded,
                  color: Appcolors.cardGreen,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.push('/smart-map');
                },
                child: QuickAccessCard(
                  title: smartMapTitle,
                  subtitle: smartMapSubtitle,
                  icon: Icons.map_outlined,
                  color: Appcolors.cardBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // This block renders the Accessibility Hub quick access card.
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
                // This block renders the accessibility icon.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Appcolors.rateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Appcolors.rateColor,
                  ),
                ),

                const SizedBox(width: 16),

                // This block renders the accessibility title, subtitle, and description.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr("accessibility"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      Text(
                        context.tr("guidelines"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr("learn_rights"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // This block renders the navigation arrow for the accessibility card.
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