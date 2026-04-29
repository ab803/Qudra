import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../widgets/booking_date_time_section.dart';
import '../widgets/booking_notes_field.dart';
import '../widgets/booking_summary_card.dart';

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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );
    if (result == null) return;
    setState(() => _selectedDate = result);
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result == null) return;
    final formatted =
        '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
    setState(() => _selectedTime = formatted);
  }

  void _continueToPaymentMethods() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('booking_select_datetime_error')),
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
        title: Text(context.tr('booking_checkout_title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSummaryCard(
                institution: widget.institution,
                service: widget.service,
                requestedDate: _selectedDate,
                requestedTime: _selectedTime,
                notes: _notesController.text.trim(),
              ),
              const SizedBox(height: 20),
              BookingDateTimeSection(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onSelectDate: _pickDate,
                onSelectTime: _pickTime,
              ),
              const SizedBox(height: 20),
              BookingNotesField(controller: _notesController),
              const SizedBox(height: 24),
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
                    context.tr('booking_continue_to_payment'),
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