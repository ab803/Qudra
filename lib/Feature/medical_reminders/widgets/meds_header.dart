import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class MedsHeader extends StatelessWidget {
  const MedsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Medical Reminders',
              style: AppTextStyles.title.copyWith(
                fontSize: 28,
                color: Appcolors.primaryColor,
                height: 1.05,
              ),
            ),
          ],
        ),
      ],
    );
  }
}