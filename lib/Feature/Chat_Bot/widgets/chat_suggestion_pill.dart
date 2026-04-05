import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

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
    final bgColor = isCritical
        ? Colors.red.shade50
        : Colors.grey.shade100;
    final fgColor = isCritical
        ? Colors.red.shade700
        : Appcolors.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCritical
                ? Colors.red.shade200
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
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