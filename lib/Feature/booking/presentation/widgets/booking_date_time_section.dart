import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

// This widget renders the date selector and available times used in the booking checkout screen.
class BookingDateTimeSection extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final VoidCallback onSelectDate;
  final List<String> availableSlots;
  final ValueChanged<String> onSelectSlot;

  const BookingDateTimeSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.availableSlots,
    required this.onSelectSlot,
  });

  // This helper formats the selected booking date for the UI.
  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return context.tr("booking_select_date");
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // This block renders the title above the date and time selectors.
        Text(
          context.tr("booking_datetime_section_title"),
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),

        // This block renders the date selector tile.
        _PickerTile(
          icon: Icons.calendar_month_outlined,
          title: context.tr("booking_preferred_date"),
          value: _formatDate(context, selectedDate),
          onTap: onSelectDate,
        ),
        const SizedBox(height: 12),

        // This block renders the available time choices for the selected day.
        _SlotsSection(
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          availableSlots: availableSlots,
          onSelectSlot: onSelectSlot,
        ),
      ],
    );
  }
}

// This widget renders the available time list for the selected booking day.
class _SlotsSection extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<String> availableSlots;
  final ValueChanged<String> onSelectSlot;

  const _SlotsSection({
    required this.selectedDate,
    required this.selectedTime,
    required this.availableSlots,
    required this.onSelectSlot,
  });

  // This helper converts HH:mm values into a 12-hour display format.
  String _formatTimeTo12Hour(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteText $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedDate == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(
          context.tr("booking_choose_day_first_for_times"),
        ),
      );
    }

    if (availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(
          context.tr("booking_no_available_times_for_day"),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr("booking_choose_suitable_time"),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSlots.map((slot) {
              final isSelected = selectedTime == slot;

              return ChoiceChip(
                label: Text(_formatTimeTo12Hour(slot)),
                selected: isSelected,
                onSelected: (_) => onSelectSlot(slot),
                selectedColor: Colors.black,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.black : Colors.black26,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// This widget renders a single tap-able picker tile for day selection.
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.22 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}