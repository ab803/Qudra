import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This list defines the visible category chips and the matching institution filter value.
    final categories = [
      {
        'icon': Icons.accessible,
        'label': context.tr("physical"),
        'color': Appcolors.cardOrange,
        'filter': 'Mobility',
      },
      {
        'icon': Icons.visibility,
        'label': context.tr("visual"),
        'color': Appcolors.rateColor,
        'filter': 'Vision',
      },
      {
        'icon': Icons.hearing,
        'label': context.tr("hearing"),
        'color': Appcolors.cardTeal,
        'filter': 'Hearing',
      },
      {
        'icon': Icons.psychology_alt_rounded,
        'label': context.tr("disability_cognitive"),
        'color': Appcolors.cardPurple,
        'filter': 'Cognitive',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Text(
              context.tr("categories"),
              style: AppTextStyles.title.copyWith(
                fontSize: 18,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal list of category chips
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final String targetFilter = category['filter'] as String;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    final destination = Uri(
                      path: '/institution',
                      queryParameters: {
                        'filter': targetFilter,
                      },
                    ).toString();

                    context.push(destination);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            theme.brightness == Brightness.dark ? 0.14 : 0.03,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['label'] as String,
                          style: AppTextStyles.body.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}