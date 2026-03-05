import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class DisabilityProfileCard extends StatelessWidget {
  const DisabilityProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Appcolors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.accessibility_new_rounded,
                    size: 18, color: Appcolors.primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Disability Profile',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Appcolors.primaryColor,
                  ),
                ),
              ),
              Text(
                'Edit',
                style: AppTextStyles.body.copyWith(
                  color: Appcolors.cardBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'This information helps us tailor accessibility features specifically for you.',
              style: AppTextStyles.body.copyWith(
                color: Appcolors.secondaryColor,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Appcolors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.visibility_outlined,
                      color: Appcolors.primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visual Impairment',
                        style: AppTextStyles.body.copyWith(
                          color: Appcolors.primaryColor,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Low vision mode active',
                        style: AppTextStyles.body.copyWith(
                          color: Appcolors.secondaryColor,
                          fontSize: 12,
                          height: 1.0,
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