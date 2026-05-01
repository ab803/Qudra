import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

// This widget renders the optional notes field for the booking checkout screen.
class BookingNotesField extends StatelessWidget {
  final TextEditingController controller;

  const BookingNotesField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This block renders the notes label above the input field.
        Text(
          context.tr("booking_notes_title"),
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),

        // This block renders the text field used to capture optional booking notes.
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: context.tr("booking_notes_hint"),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}