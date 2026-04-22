import 'package:flutter/material.dart';

class A11ySearchBar extends StatelessWidget {
  final String hintText;

  const A11ySearchBar({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: onSurface.withOpacity(0.55),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hintText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withOpacity(0.55),
                fontSize: 13.5,
                height: 1.1,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.tune,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}