import 'package:flutter/material.dart';

class PostSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const PostSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.08 : 0.04,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search posts',
          hintStyle: TextStyle(
            color: onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}