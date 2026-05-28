import 'package:flutter/material.dart';

class QuickAccessCard extends StatelessWidget {
  // Card content
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const QuickAccessCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 110,
      padding: const EdgeInsets.all(14),

      // Colored card with shadow
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(
              theme.brightness == Brightness.dark ? 0.22 : 0.30,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const Spacer(),

          // Title
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}