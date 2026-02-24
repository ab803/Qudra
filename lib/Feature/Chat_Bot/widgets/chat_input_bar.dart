import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // صندوق الإدخال (placeholder فقط)
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Appcolors.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Type a message…',
                      style: AppTextStyles.body.copyWith(
                        color: Appcolors.textLight,
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file, color: Appcolors.textLight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // أزرار دائرية داخل مربعات سوداء (زي السكرين)
          _SquareIcon(icon: Icons.mic_none_rounded),
          const SizedBox(width: 8),
          _SquareIcon(icon: Icons.play_arrow_rounded), // send
        ],
      ),
    );
  }
}

class _SquareIcon extends StatelessWidget {
  final IconData icon;
  const _SquareIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Appcolors.primaryColor, // أسود
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}