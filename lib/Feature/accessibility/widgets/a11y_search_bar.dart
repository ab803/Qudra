import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class A11ySearchBar extends StatelessWidget {
  final String hintText;
  const A11ySearchBar({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Appcolors.textLight, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hintText,
              style: AppTextStyles.body.copyWith(
                color: Appcolors.textLight,
                fontSize: 13.5,
                height: 1.1,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 20, color: Appcolors.primaryColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}