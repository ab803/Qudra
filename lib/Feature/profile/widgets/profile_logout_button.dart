import 'package:flutter/material.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Log Out",
          style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}