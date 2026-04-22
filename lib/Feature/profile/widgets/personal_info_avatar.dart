import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class PersonalInfoAvatar extends StatelessWidget {
  const PersonalInfoAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primary,
              child: CircleAvatar(
                radius: 42,
                backgroundColor: theme.cardColor,
                backgroundImage:
                const AssetImage('assets/images/avatar_placeholder.png'),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Appcolors.cardBlue,
                shape: BoxShape.circle,
                border: Border.all(color: theme.cardColor, width: 2),
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