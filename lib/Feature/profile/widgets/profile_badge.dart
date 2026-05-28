import 'package:flutter/material.dart';

class ProfileBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  const ProfileBadge({
    super.key,
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
