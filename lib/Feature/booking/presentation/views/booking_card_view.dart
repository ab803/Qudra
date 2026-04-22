import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../../viewmodel/booking_cubit.dart';
import '../../viewmodel/booking_state.dart';
import '../widgets/booking_summary_card.dart';

// This screen starts the online card payment flow after the user confirms the booking summary.
class BookingCardView extends StatefulWidget {
  final InstitutionModel institution;
  final InstitutionServiceModel service;
  final DateTime requestedDate;
  final String requestedTime;
  final String? notes;

  const BookingCardView({
    super.key,
    required this.institution,
    required this.service,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
  });

  @override
  State<BookingCardView> createState() => _BookingCardViewState();
}

class _BookingCardViewState extends State<BookingCardView> {
  // This helper opens the Paymob checkout URL and moves the user to the processing screen.
  Future<void> _openCheckoutAndProceed(
      String bookingId,
      String checkoutUrl,
      ) async {
    final uri = Uri.parse(checkoutUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the payment checkout page.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    context.pushReplacement(
      '/booking/processing',
      extra: {
        'bookingId': bookingId,
      },
    );
  }

  // This helper sends the booking request using the card payment method.
  void _payWithCard() {
    context.read<BookingCubit>().createBookingSession(
      serviceId: widget.service.id,
      institutionId: widget.institution.id,
      requestedDate: widget.requestedDate,
      requestedTime: widget.requestedTime,
      paymentMethod: 'card',
      notes: widget.notes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) async {
        if (state is BookingSessionCreated) {
          await _openCheckoutAndProceed(
            state.bookingId,
            state.checkoutUrl,
          );
        }

        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
            ),
          );
        }

        if (state is BookingConfirmed) {
          // ✅ Updated: keep the result route contract consistent by sending bookingId only.
          context.pushReplacement(
            '/booking/result',
            extra: {
              'bookingId': state.booking.id,
            },
          );
        }

        if (state is BookingFailed) {
          final bookingId = state.booking?.id;
          if (bookingId != null) {
            // ✅ Updated: keep the result route contract consistent by sending bookingId only.
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
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isLoading = state is BookingLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Card Payment'),
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
                    requestedDate: widget.requestedDate,
                    requestedTime: widget.requestedTime,
                    notes: widget.notes,
                  ),
                  const SizedBox(height: 20),
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
                      'When you press pay, Paymob test checkout will open so you can complete the card payment securely.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _payWithCard,
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
                        'Pay with Card',
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