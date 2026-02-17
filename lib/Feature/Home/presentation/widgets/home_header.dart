import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/Styles/AppColors.dart';
import '../../../../core/Styles/AppTextsyles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Welcome text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 4),

            // User name
            Text(
              'Hello, Ahmed',
              style: AppTextStyles.subtitle.copyWith(
                color: Appcolors.primaryColor,
              ),
            ),
          ],
        ),

        // Dark mode button (icon only for now)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Appcolors.primaryColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.nightlight_round,
            color: Appcolors.primaryColor,
          ),
        ),
      ],
    );
  }
}
