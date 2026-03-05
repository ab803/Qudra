import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class PersonalInfoAvatar extends StatelessWidget {
  const PersonalInfoAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/avatar_placeholder.png'),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Appcolors.cardBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}