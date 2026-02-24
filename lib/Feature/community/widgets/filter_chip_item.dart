import 'package:flutter/material.dart';

import '../../../core/Styles/AppColors.dart';

class FilterChipItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const FilterChipItem({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ?Appcolors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Appcolors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}