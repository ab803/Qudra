import 'package:flutter/material.dart';
import '../../../core/Styles/AppColors.dart';
import 'action_item.dart';

class UserPostCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String body;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool showMoreButton;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const UserPostCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.body,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.showMoreButton = true,
    this.onMoreTap,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final likeColor = isLiked ? Colors.red : Appcolors.secondaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Appcolors.primaryColor.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
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
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ActionItem(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: likesCount.toString(),
                  iconColor: likeColor,
                  textColor: likeColor,
                  onTap: onLikeTap,
                ),
                const SizedBox(width: 24),
                ActionItem(
                  icon: Icons.chat_bubble_outline,
                  label: commentsCount.toString(),
                  onTap: onCommentTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}