import 'package:flutter/material.dart';

// This widget renders the top page header.
class InstitutionTopHeader extends StatelessWidget {
  const InstitutionTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Qudra',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          Icons.account_circle,
          size: 32,
          color: theme.iconTheme.color,
        ),
      ],
    );
  }
}