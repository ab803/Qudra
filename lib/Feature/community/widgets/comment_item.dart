import 'package:flutter/material.dart';
import '../../../core/Styles/AppColors.dart';

class CommentItem extends StatelessWidget {
  final String authorName;
  final String subtitle;
  final String content;
  final bool showMoreButton;
  final VoidCallback? onMoreTap;

  const CommentItem({
    super.key,
    required this.authorName,
    required this.subtitle,
    required this.content,
    this.showMoreButton = false,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Appcolors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (showMoreButton)
                IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(Icons.more_horiz),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}