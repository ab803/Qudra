import 'package:flutter/material.dart';

// This widget renders the reusable institutions search field.
class InstitutionSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const InstitutionSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.22 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          icon: const Icon(Icons.search),
          hintText: 'Search institutions...',
          border: InputBorder.none,
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
            // This button clears the current search text.
            onPressed: onClear,
            icon: const Icon(Icons.close),
          ),
        ),
      ),
    );
  }
}