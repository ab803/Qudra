import 'package:flutter/material.dart';
import 'profile_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary,
                child: CircleAvatar(
                  radius: 58,
                  backgroundImage:
                  const NetworkImage('https://placeholder.com/user_avatar'),
                  backgroundColor: theme.scaffoldBackgroundColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Ahmed Ali",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          Text(
            "Visual Assistance Mode",
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileBadge(
                icon: Icons.workspace_premium,
                text: "Premium",
                bgColor: Colors.blue.shade50,
                textColor: Colors.blue,
              ),
              const SizedBox(width: 12),
              ProfileBadge(
                icon: Icons.check_circle,
                text: "Verified",
                bgColor: Colors.green.shade50,
                textColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}