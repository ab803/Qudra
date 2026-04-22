import 'package:flutter/material.dart';

class ChatSuggestionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCritical;
  final VoidCallback? onTap; // ✅ wired to cubit

  const ChatSuggestionPill({
    super.key,
    required this.label,
    required this.icon,
    this.isCritical = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color fgColor = isCritical
        ? colorScheme.error
        : colorScheme.primary;

    final Color bgColor = isCritical
        ? colorScheme.error.withOpacity(
      theme.brightness == Brightness.dark ? 0.16 : 0.08,
    )
        : theme.cardColor;

    final Color borderColor = isCritical
        ? colorScheme.error.withOpacity(0.24)
        : theme.dividerColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
