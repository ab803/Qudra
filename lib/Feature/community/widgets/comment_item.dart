import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              if (showMoreButton)
                IconButton(
                  onPressed: onMoreTap,
                  icon: Icon(
                    Icons.more_horiz,
                    color: onSurface.withOpacity(0.72),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
