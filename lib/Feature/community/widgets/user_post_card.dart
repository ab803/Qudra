import 'package:flutter/material.dart';
import 'action_item.dart';

class UserPostCard extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final String subtitle;
  final String tagText;
  final String title;
  final String body;
  final bool hasImage;
  final String likes;
  final String comments;

  const UserPostCard({
    super.key,
    this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.tagText,
    required this.title,
    required this.body,
    this.hasImage = false,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(avatarUrl!)),
                const SizedBox(width: 12),
                Expanded(child: Text(name)),
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 12),
            Text(title,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 12),
            Row(
              children: [
                ActionItem(icon: Icons.favorite_border, label: likes),
                const SizedBox(width: 24),
                ActionItem(icon: Icons.chat_bubble_outline, label: comments),
              ],
            ),
          ],
        ),
      ),
    );
  }
}