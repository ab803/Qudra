import 'package:flutter/material.dart';
import '../../../../core/Styles/AppColors.dart';

class PostSearchBar extends StatelessWidget {
  const PostSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: MediaQuery.of(context).size.width*0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16),

      // Card styling
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Appcolors.primaryColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      // Input field
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search posts ',
          hintStyle: const TextStyle(color: Appcolors.secondaryColor),
          border: InputBorder.none,

          // Search icon
          icon: const Icon(Icons.search, color: Appcolors.secondaryColor),
        ),
      ),
    );
  }
}
