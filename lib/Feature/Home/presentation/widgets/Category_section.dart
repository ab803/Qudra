import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/Styles/AppColors.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
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
      {'icon': Icons.hearing, 'label': 'Hearing', 'color': Appcolors.cardTeal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Appcolors.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: Appcolors.cardBlue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Appcolors.textDark,
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