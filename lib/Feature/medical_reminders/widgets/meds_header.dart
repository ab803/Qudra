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
        Text(
          'GOOD MORNING',
          style: AppTextStyles.body.copyWith(
            letterSpacing: 1.2,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Appcolors.secondaryColor,
            height: 1.0,
          ),
        ),
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
            const Spacer(),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.accessibility_new_rounded,
                  color: Appcolors.primaryColor, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}