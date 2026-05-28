import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class DisabilityProfileCard extends StatelessWidget {
  final String disabilityType;

  const DisabilityProfileCard({
    super.key,
    required this.disabilityType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = _DisabilityVisualDetails.fromType(context, disabilityType);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.14 : 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: details.accentColor.withOpacity(
                    theme.brightness == Brightness.dark ? 0.22 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  details.leadingIcon,
                  size: 22,
                  color: details.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr("disability_profile"),
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr("disability_description"),
                      style: AppTextStyles.body.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: details.accentColor.withOpacity(
                      theme.brightness == Brightness.dark ? 0.18 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    details.trailingIcon,
                    color: details.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details.typeLabel,
                        style: AppTextStyles.body.copyWith(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details.description,
                        style: AppTextStyles.body.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
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

class _DisabilityVisualDetails {
  final IconData leadingIcon;
  final IconData trailingIcon;
  final Color accentColor;
  final String typeLabel;
  final String description;

  const _DisabilityVisualDetails({
    required this.leadingIcon,
    required this.trailingIcon,
    required this.accentColor,
    required this.typeLabel,
    required this.description,
  });

  factory _DisabilityVisualDetails.fromType(BuildContext context, String type) {
    switch (type.trim().toLowerCase()) {
      case 'visual':
        return _DisabilityVisualDetails(
          leadingIcon: Icons.visibility_outlined,
          trailingIcon: Icons.visibility_rounded,
          accentColor: Appcolors.rateColor,
          typeLabel: context.tr("disability_visual"),
          description: context.tr("subtitle_visual"),
        );
      case 'hearing':
        return _DisabilityVisualDetails(
          leadingIcon: Icons.hearing_rounded,
          trailingIcon: Icons.hearing_rounded,
          accentColor: Appcolors.cardTeal,
          typeLabel: context.tr("disability_hearing"),
          description: context.tr("subtitle_hearing"),
        );
      case 'physical':
        return _DisabilityVisualDetails(
          leadingIcon: Icons.accessible_rounded,
          trailingIcon: Icons.accessibility_new_rounded,
          accentColor: Appcolors.cardOrange,
          typeLabel: context.tr("disability_physical"),
          description: context.tr("subtitle_physical"),
        );
      case 'cognitive':
        return _DisabilityVisualDetails(
          leadingIcon: Icons.psychology_alt_rounded,
          trailingIcon: Icons.psychology_alt_rounded,
          accentColor: Appcolors.cardPurple,
          typeLabel: context.tr("disability_cognitive"),
          description: context.tr("subtitle_cognitive"),
        );
      default:
        return _DisabilityVisualDetails(
          leadingIcon: Icons.adjust_rounded,
          trailingIcon: Icons.stars_rounded,
          accentColor: Appcolors.cardBlue,
          typeLabel: context.tr("disability_other"),
          description: context.tr("subtitle_other"),
        );
    }
  }
}
