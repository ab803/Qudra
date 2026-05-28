import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class PersonalInfoAvatar extends StatelessWidget {
  final String displayName;

  const PersonalInfoAvatar({
    super.key,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _extractInitials(displayName);

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Appcolors.cardBlue.withOpacity(0.92),
                Appcolors.cardTeal,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Appcolors.cardTeal.withOpacity(
                  theme.brightness == Brightness.dark ? 0.28 : 0.16,
                ),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _extractInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1).toUpperCase()}${parts.last.substring(0, 1).toUpperCase()}';
  }
}