import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/Styles/AppColors.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search institutions or guidelines...',
          hintStyle: const TextStyle(color: Appcolors.secondaryColor),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Appcolors.secondaryColor),
        ),
      ),
    );
  }
}