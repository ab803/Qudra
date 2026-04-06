import 'package:flutter/material.dart';
import '../../../core/Styles/AppColors.dart';

class PostSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const PostSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search posts',
          hintStyle: TextStyle(color: Appcolors.secondaryColor),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Appcolors.secondaryColor),
        ),
      ),
    );
  }
}