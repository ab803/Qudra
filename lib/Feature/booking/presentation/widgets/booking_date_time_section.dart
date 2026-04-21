import 'package:flutter/material.dart';

// This widget renders the date and time pickers used in the booking checkout screen.
class BookingDateTimeSection extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const BookingDateTimeSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  // This helper formats the selected booking date for the UI.
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select a date';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This block renders the title above the date and time selectors.
        const Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),

        // This block renders the date selector tile.
        _PickerTile(
          icon: Icons.calendar_month_outlined,
          title: 'Preferred Date',
          value: _formatDate(selectedDate),
          onTap: onSelectDate,
        ),
        const SizedBox(height: 12),

        // This block renders the time selector tile.
        _PickerTile(
          icon: Icons.access_time_outlined,
          title: 'Preferred Time',
          value: selectedTime ?? 'Select a time',
          onTap: onSelectTime,
        ),
      ],
    );
  }
}

// This widget renders a single tap-able picker tile for date or time input.
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}