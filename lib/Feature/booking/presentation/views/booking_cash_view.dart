import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../../viewmodel/booking_cubit.dart';
import '../../viewmodel/booking_state.dart';
import '../widgets/booking_summary_card.dart';

// This screen confirms the booking immediately and marks the payment as due at the institution.
class BookingCashView extends StatelessWidget {
  final InstitutionModel institution;
  final InstitutionServiceModel service;
  final DateTime requestedDate;
  final String requestedTime;
  final String? notes;

  const BookingCashView({
    super.key,
    required this.institution,
    required this.service,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
  });

  // This helper starts the direct cash booking confirmation flow.
  void _confirmCashBooking(BuildContext context) {
    context.read<BookingCubit>().createBookingSession(
      serviceId: service.id,
      institutionId: institution.id,
      requestedDate: requestedDate,
      requestedTime: requestedTime,
      paymentMethod: 'cash_at_institution',
      notes: notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        // ✅ Updated:
        // Navigate to the result route using bookingId only,
        // because /booking/result expects { 'bookingId': ... } in state.extra.
        if (state is BookingConfirmed) {
          context.pushReplacement(
            '/booking/result',
            extra: {
              'bookingId': state.booking.id,
            },
          );
        }

        // ✅ Updated:
        // Keep the same route contract on failed states too.
        // If no booking id exists, show the error locally instead of crashing the route.
        if (state is BookingFailed) {
          final bookingId = state.booking?.id;
          if (bookingId != null) {
            context.pushReplacement(
              '/booking/result',
              extra: {
                'bookingId': bookingId,
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
              ),
            );
          }
        }

        // This block shows unexpected booking errors in a snackbar.
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
            ),
          );
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isLoading = state is BookingLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cash at Institution'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This block shows the booking summary before cash confirmation.
                  BookingSummaryCard(
                    institution: institution,
                    service: service,
                    requestedDate: requestedDate,
                    requestedTime: requestedTime,
                    notes: notes,
                  ),
                  const SizedBox(height: 20),

                  // This block explains the cash-at-institution payment rule.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                    ),
                    child: Text(
                      'Your booking will be confirmed immediately, and payment will be collected at the institution.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // This block confirms the cash booking directly without opening Paymob.
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                      isLoading ? null : () => _confirmCashBooking(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2.4,
                        ),
                      )
                          : Text(
                        'Confirm Booking',
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
      },
    );
  }
}