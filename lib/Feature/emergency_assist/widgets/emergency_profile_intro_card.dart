import 'package:flutter/material.dart';

class EmergencyProfileIntroCard extends StatelessWidget {
  const EmergencyProfileIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.badge_outlined,
              size: 36,
              color: Color(0xFF0D6EFD),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلوماتك\nالمنقذة للحياة',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0D6EFD),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هذه البيانات تساعد فرق الطوارئ أو مقدم الدعم المناسب للوصول إليك بسرعة وقت الحاجة.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}