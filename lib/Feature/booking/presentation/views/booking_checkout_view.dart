import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../widgets/booking_date_time_section.dart';
import '../widgets/booking_notes_field.dart';
import '../widgets/booking_summary_card.dart';

// This screen collects the booking date, time, and optional notes before payment selection.
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

  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // This helper opens the date picker and stores the selected date in state.
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
    });
  }

  // This helper opens the time picker and stores the selected time in HH:mm format.
  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (result == null) return;

    final formatted =
        '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';

    setState(() {
      _selectedTime = formatted;
    });
  }

  // This helper validates the booking form and moves to the payment method screen.
  void _continueToPaymentMethods() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time first.'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Service',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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

              // This block renders the booking date and time selectors.
              BookingDateTimeSection(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onSelectDate: _pickDate,
                onSelectTime: _pickTime,
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
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(
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