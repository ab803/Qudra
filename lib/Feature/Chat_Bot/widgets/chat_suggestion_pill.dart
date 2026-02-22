import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class ChatSuggestionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isCritical; // علشان لون خاص للطوارئ

  const ChatSuggestionPill({
    super.key,
    required this.label,
    required this.icon,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCritical
        ? Appcolors.EmergancyColor.withOpacity(0.08)
        : Appcolors.backgroundColor;
    final fg = isCritical ? Appcolors.EmergancyColor : Appcolors.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}