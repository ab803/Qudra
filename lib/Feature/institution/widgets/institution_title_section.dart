import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

class InstitutionTitleSection extends StatelessWidget {
  const InstitutionTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr('institution_title'),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}