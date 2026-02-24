import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Appcolors.secondaryColor),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Appcolors.secondaryColor)),
      ],
    );
  }
}