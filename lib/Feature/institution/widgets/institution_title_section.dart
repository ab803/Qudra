import 'package:flutter/material.dart';

// This widget renders the institutions page title.
class InstitutionTitleSection extends StatelessWidget {
  const InstitutionTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Support Centers',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
