import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Utilies/getit.dart';
import '../../models/booking_model.dart';
import '../../models/booking_payment_model.dart';
import '../../services/booking_service.dart';

class BookingResultView extends StatefulWidget {
  final String bookingId;

  const BookingResultView({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingResultView> createState() => _BookingResultViewState();
}

class _BookingResultViewState extends State<BookingResultView> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<BookingService>().getBookingSnapshot(widget.bookingId);
  }

  String _paymentMethodLabel(String? method) {
    switch (method) {
      case 'card':
        return 'Card';
      case 'wallet':
        return 'Wallet';
      case 'cash_at_institution':
        return 'Cash at Institution';
      default:
        return 'Unknown';
    }
  }

  String _prettyStatus(String value) {
    if (value.trim().isEmpty) return 'Unknown';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1)}',
    )
        .join(' ');
  }

  _ResultPresentation _buildPresentation(
      BuildContext context,
      BookingModel? booking,
      BookingPaymentModel? payment,
      ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (booking == null) {
      return _ResultPresentation(
        title: 'Booking Not Found',
        message: 'We could not load this booking right now.',
        icon: Icons.help_outline,
        accent: onSurface,
      );
    }

    final bookingStatus = booking.bookingStatus.toLowerCase();
    final paymentStatus =
    (payment?.paymentStatus ?? booking.paymentStatus).toLowerCase();

    if (bookingStatus == 'confirmed') {
      return const _ResultPresentation(
        title: 'Booking Confirmed',
        message: 'Your booking was confirmed successfully.',
        icon: Icons.check_circle_outline,
        accent: Colors.green,
      );
    }

    if (bookingStatus == 'pending_payment' || paymentStatus == 'pending') {
      return const _ResultPresentation(
        title: 'Still Processing',
        message:
        'Paymob has returned you to the app, but the final callback has not finished updating the booking yet. You can check again shortly from Home.',
        icon: Icons.hourglass_top_rounded,
        accent: Colors.orange,
      );
    }

    if (bookingStatus == 'cancelled') {
      return _ResultPresentation(
        title: 'Booking Cancelled',
        message: 'The payment session was cancelled or voided.',
        icon: Icons.remove_circle_outline,
        accent: onSurface,
      );
    }

    return const _ResultPresentation(
      title: 'Booking Failed',
      message: 'The payment was not completed successfully.',
      icon: Icons.error_outline,
      accent: Colors.red,
    );
  }

  // ✅ Updated:
  // Always go to Home from the result screen instead of popping back
  // to any previous booking-related screen.
  void _goHome() {
    context.go('/home');
  }

  // ✅ Updated:
  // Handle Android/system back and force navigation to Home.
  Future<bool> _handleBackNavigation() async {
    _goHome();
    return false;
  }

  // ✅ Updated:
  // Custom app bar back button that always goes to Home.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _goHome,
      ),
      title: const Text('Booking Result'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return WillPopScope(
            onWillPop: _handleBackNavigation,
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return WillPopScope(
            onWillPop: _handleBackNavigation,
            child: Scaffold(
              appBar: _buildAppBar(),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load booking result right now.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            // ✅ Updated:
                            // Bottom action now goes to Home.
                            onPressed: _goHome,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Back to Home',
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
              ),
            ),
          );
        }

        final booking = snapshot.data?['booking'] as BookingModel?;
        final payment = snapshot.data?['payment'] as BookingPaymentModel?;
        final presentation = _buildPresentation(context, booking, payment);

        return WillPopScope(
          onWillPop: _handleBackNavigation,
          child: Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: presentation.accent.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          presentation.icon,
                          size: 46,
                          color: presentation.accent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        presentation.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        presentation.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (booking != null)
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ResultRow(
                                label: 'Booking ID',
                                value: booking.id,
                              ),
                              _ResultRow(
                                label: 'Booking Status',
                                value: _prettyStatus(booking.bookingStatus),
                              ),
                              _ResultRow(
                                label: 'Payment Method',
                                value: _paymentMethodLabel(booking.paymentMethod),
                              ),
                              _ResultRow(
                                label: 'Payment Status',
                                value: _prettyStatus(
                                  payment?.paymentStatus ?? booking.paymentStatus,
                                ),
                              ),
                              _ResultRow(
                                label: 'Requested Date',
                                value: booking.requestedDate
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                              ),
                              _ResultRow(
                                label: 'Requested Time',
                                value: booking.requestedTime,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          // ✅ Updated:
                          // Bottom action always goes to Home.
                          onPressed: _goHome,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Back to Home',
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
            ),
          ),
        );
      },
    );
  }
}

class _ResultPresentation {
  final String title;
  final String message;
  final IconData icon;
  final Color accent;

  const _ResultPresentation({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
  });
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}