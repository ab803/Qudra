import 'package:flutter/material.dart';
import 'profile_badge.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 58,
                  backgroundImage:
                  NetworkImage('https://placeholder.com/user_avatar'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.visibility,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Ahmed Ali",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Visual Assistance Mode",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileBadge(
                  icon: Icons.workspace_premium,
                  text: "Premium",
                  bgColor: Colors.blue.shade50,
                  textColor: Colors.blue),
              const SizedBox(width: 12),
              ProfileBadge(
                  icon: Icons.check_circle,
                  text: "Verified",
                  bgColor: Colors.green.shade50,
                  textColor: Colors.green),
            ],
          ),
        ],
      ),
    );
  }
}