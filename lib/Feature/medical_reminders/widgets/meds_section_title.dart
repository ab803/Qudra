import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class MedsSectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;

  const MedsSectionTitle({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Appcolors.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w800,
            color: labelColor ?? Appcolors.textDark,
          ),
        ),
      ],
    );
  }
}