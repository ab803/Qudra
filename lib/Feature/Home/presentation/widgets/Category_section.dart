import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {

    // List of categories displayed horizontally
    final categories = [
      {
        'icon': Icons.accessible,
        'label': 'Physical',
        'color': Appcolors.cardOrange,
      },
      {
        'icon': Icons.visibility,
        'label': 'Visual',
        'color': Appcolors.rateColor,
      },
      {
        'icon': Icons.hearing,
        'label': 'Hearing',
        'color': Appcolors.cardTeal,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Section title
        Row(
          children: [
            Text(
              'Categories',
              style: AppTextStyles.title.copyWith(fontSize: 18),
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

            // spacing between items
            separatorBuilder: (context, index) => const SizedBox(width: 12),

            itemBuilder: (context, index) {
              final category = categories[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),

                  // soft shadow
                  boxShadow: [
                    BoxShadow(
                      color: Appcolors.primaryColor.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                // Icon + label
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
                        color: Appcolors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
