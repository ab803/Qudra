import 'package:flutter/material.dart';
import '../../../core/widgets/adaptive_logo.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: const Center(
              // This block renders the correct community logo asset for the active theme.
              child: AdaptiveLogo(
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Community Feed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}