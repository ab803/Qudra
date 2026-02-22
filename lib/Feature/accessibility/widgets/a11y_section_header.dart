import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class A11ySectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const A11ySectionHeader({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Appcolors.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.title.copyWith(
            fontSize: 18,
            color: Appcolors.textDark,
          ),
        ),
      ],
    );
  }
}