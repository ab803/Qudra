import 'package:flutter/material.dart';

// This widget renders the top page header.
class InstitutionTopHeader extends StatelessWidget {
  const InstitutionTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Qudra',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Icon(Icons.account_circle, size: 32),
      ],
    );
  }
}
