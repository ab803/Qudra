import 'package:flutter/material.dart';
import '../../../core/Styles/AppIcons.dart';
import '../../../core/Styles/AppTextsyles.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                Appicons.logo,
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Community Feed',
              style: AppTextStyles.title.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}