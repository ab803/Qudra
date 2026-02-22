import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class PersonalContactsSection extends StatelessWidget {
  const PersonalContactsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'PERSONAL CONTACTS',
              style: AppTextStyles.body.copyWith(
                letterSpacing: 2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Appcolors.secondaryColor,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // UI فقط حالياً
              },
              child: Text(
                'Edit List',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Appcolors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        const _ContactTile(name: 'Mom', subtitle: 'Primary Contact'),
        const SizedBox(height: 12),
        const _ContactTile(name: 'John Doe', subtitle: 'Partner'),
        const SizedBox(height: 12),
        const _ContactTile(name: 'Dr. Smith', subtitle: 'General Practitioner'),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String subtitle;

  const _ContactTile({
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Appcolors.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person, color: Appcolors.secondaryColor),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.subtitle.copyWith(
                    color: Appcolors.primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.body),
              ],
            ),
          ),

          // Call button (UI فقط)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Appcolors.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.call, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}