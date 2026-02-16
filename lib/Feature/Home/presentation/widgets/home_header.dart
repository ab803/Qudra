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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Welcome',
                style: AppTextStyles.title
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, Ahmed',
              style: AppTextStyles.subtitle.copyWith(color: Appcolors.primaryColor),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
