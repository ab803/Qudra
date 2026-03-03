import 'package:flutter/material.dart';
import '../../core/Styles/AppColors.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_logout_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  ProfileMenuItem(
                      icon: Icons.person,
                      title: "Personal Info",
                      iconBg: Colors.orange.shade100,
                      iconColor: Colors.orange),

                  ProfileMenuItem(
                      icon: Icons.collections_bookmark,
                      title: "My Subscriptions",
                      iconBg: Colors.yellow.shade100,
                      iconColor: Colors.yellow.shade700),

                  const SizedBox(height: 25),

                  const Text("Support & Settings",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  ProfileMenuItem(
                      icon: Icons.menu_book,
                      title: "App Guidelines",
                      iconBg: Colors.teal.shade100,
                      iconColor: Colors.teal),

                  ProfileMenuItem(
                      icon: Icons.chat_bubble,
                      title: "Feedback",
                      iconBg: Colors.blue.shade100,
                      iconColor: Colors.blue),

                  ProfileMenuItem(
                      icon: Icons.settings,
                      title: "Settings",
                      iconBg: Colors.grey.shade200,
                      iconColor: Colors.grey.shade700),

                  const SizedBox(height: 30),

                  const ProfileLogoutButton(),

                  const SizedBox(height: 30),

                  const Center(
                    child: Text(
                      "«With you to discover your ability»",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}