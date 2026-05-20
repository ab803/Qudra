import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../../services/booking_service.dart';
import '../widgets/booking_date_time_section.dart';
import '../widgets/booking_notes_field.dart';
import '../widgets/booking_summary_card.dart';

// This screen collects the booking day, available slot, and optional notes before payment selection.
class BookingCheckoutView extends StatefulWidget {
  final InstitutionModel institution;
  final InstitutionServiceModel service;

  const BookingCheckoutView({
    super.key,
    required this.institution,
    required this.service,
  });

  @override
  State<BookingCheckoutView> createState() => _BookingCheckoutViewState();
}

class _BookingCheckoutViewState extends State<BookingCheckoutView> {
  final TextEditingController _notesController = TextEditingController();

  // This service loads reserved slots for the selected service day.
  final BookingService _bookingService = BookingService();

  DateTime? _selectedDate;
  String? _selectedTime;
  bool _isLoadingSlots = false;
  List<String> _availableSlots = [];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // This helper opens the date picker and reloads the available slots for the selected day.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );

    if (result == null) return;

    setState(() {
      _selectedDate = result;
      _selectedTime = null;
      _availableSlots = [];
      _isLoadingSlots = true;
    });

    final slots = await _loadAvailableSlots(result);

    if (!mounted) return;

    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
    });
  }

  // This helper loads the available slots for the selected day after excluding reserved times.
  Future<List<String>> _loadAvailableSlots(DateTime selectedDate) async {
    final generatedSlots = _generateSlotsForDay(selectedDate);

    if (generatedSlots.isEmpty) {
      return [];
    }

    final reservedTimes =
    await _bookingService.fetchReservedTimesForServiceDate(
      serviceId: widget.service.id,
      requestedDate: selectedDate,
    );

    final reservedSet = reservedTimes.toSet();

    return generatedSlots.where((slot) {
      if (reservedSet.contains(slot)) {
        return false;
      }

      if (_isPastSlot(selectedDate, slot)) {
        return false;
      }

      return true;
    }).toList();
  }

  // This helper generates all valid slots for the selected working day.
  List<String> _generateSlotsForDay(DateTime selectedDate) {
    final service = widget.service;

    if (service.workingDays.isEmpty ||
        service.workingStartTime == null ||
        service.workingEndTime == null) {
      return [];
    }

    final weekdayName = _weekdayName(selectedDate.weekday);

    if (!service.workingDays.contains(weekdayName)) {
      return [];
    }

    final start = _parseTime(selectedDate, service.workingStartTime!);
    final end = _parseTime(selectedDate, service.workingEndTime!);

    if (start == null || end == null) {
      return [];
    }

    final duration = Duration(minutes: service.durationMinutes);
    final slots = <String>[];
    var current = start;

    while (current.add(duration).isAtMost(end)) {
      slots.add(_formatSlotTime(current));
      current = current.add(duration);
    }

    return slots;
  }

  // This helper maps Dart weekday numbers to the service working day names.
  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  // This helper parses a stored HH:mm or HH:mm:ss time into a full DateTime for a given day.
  DateTime? _parseTime(DateTime date, String rawTime) {
    final parts = rawTime.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // This helper formats a slot DateTime into HH:mm text.
  String _formatSlotTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // This helper hides past slots when the selected date is today.
  bool _isPastSlot(DateTime selectedDate, String slotTime) {
    final today = DateTime.now();
    final selectedDayOnly =
    DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (selectedDayOnly != todayOnly) {
      return false;
    }

    final parts = slotTime.split(':');
    if (parts.length < 2) return false;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final slotDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );

    return !slotDateTime.isAfter(today);
  }

  // This helper validates the booking form and moves to the payment method screen.
  void _continueToPaymentMethods() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("booking_select_datetime_error")),
        ),
      );
      return;
    }

    context.push(
      '/booking/payment-method',
      extra: {
        'institution': widget.institution,
        'service': widget.service,
        'requestedDate': _selectedDate,
        'requestedTime': _selectedTime,
        'notes': _notesController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("booking_checkout_title")),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This block shows the selected institution and service summary.
              BookingSummaryCard(
                institution: widget.institution,
                service: widget.service,
                requestedDate: _selectedDate,
                requestedTime: _selectedTime,
                notes: _notesController.text.trim(),
              ),
              const SizedBox(height: 20),

              // This block renders the booking day selector and available slots.
              if (_isLoadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                BookingDateTimeSection(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onSelectDate: _pickDate,
                  availableSlots: _availableSlots,
                  // This callback stores the selected available slot.
                  onSelectSlot: (slot) {
                    setState(() {
                      _selectedTime = slot;
                    });
                  },
                ),
              const SizedBox(height: 20),

              // This block renders the optional notes field.
              BookingNotesField(
                controller: _notesController,
              ),
              const SizedBox(height: 24),

              // This block moves the user to payment method selection after validation.
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continueToPaymentMethods,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    context.tr("booking_continue_to_payment"),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This extension adds a small readable comparison helper for DateTime values.
extension _DateTimeComparisonExtension on DateTime {
  bool isAtMost(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }
}