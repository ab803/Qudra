import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/profile_logout_button.dart';
import '../widgets/profile_menu_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header Section ---
            Container(
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
                          backgroundImage: NetworkImage('https://placeholder.com/user_avatar'), // Replace with asset
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
                  const Text(
                    "Ahmed Ali",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Visual Assistance Mode",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

            // --- Menu Section ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ProfileMenuItem(
                      icon:Icons.person,
                      title: "Personal Info",
                      iconColor:Colors.orange,
                      iconBg: Colors.orange.shade100,
                      ontap: () {
                        context.go('/personal');
                      },),
                  ProfileMenuItem(
                      icon:Icons.collections_bookmark,
                      title: "My Subscriptions",
                      iconColor:Colors.orange,
                      iconBg: Colors.orange.shade100,
                      ontap: () {
                        context.go('/MySubscriptions');
                      },

                  ),

                  const SizedBox(height: 25),
                  const Text("Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ProfileMenuItem(
                      icon:Icons.info_outline,
                      title: "App Guidelines",
                      iconColor:Colors.teal.shade100,
                      iconBg: Colors.teal,
                      ontap: () => context.go('/AppGuidelines'),),
                  ProfileMenuItem(
                      icon:Icons.chat_bubble,
                      title:"Feedback",
                      iconColor:Colors.blue.shade100,
                      iconBg:Colors.blue,
                      ontap: () => context.go('/Feedback'),),

                  const SizedBox(height: 30),
                  ProfileLogoutButton(),

                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      "«With you to discover your ability»",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
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
