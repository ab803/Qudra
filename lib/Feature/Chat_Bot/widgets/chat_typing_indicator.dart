import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class ChatTypingIndicator extends StatelessWidget {
  final String time;
  const ChatTypingIndicator({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // بوت على الشمال
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, bottom: 6),
          child: Text(
            'Qudra AI',
            style: AppTextStyles.body.copyWith(
              color: Appcolors.secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Appcolors.cardTeal,
              child: const Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dot(),
                  const SizedBox(width: 4),
                  _dot(),
                  const SizedBox(width: 4),
                  _dot(),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 52, top: 6),
          child: Text(
            time,
            style: AppTextStyles.body.copyWith(
              fontSize: 11,
              color: Appcolors.secondaryColor,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot() => Container(
    width: 6,
    height: 6,
    decoration: BoxDecoration(
      color: Appcolors.textLight,
      borderRadius: BorderRadius.circular(3),
    ),
  );
}