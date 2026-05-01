import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
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

  String _paymentMethodLabel(BuildContext context, String? method) {
    switch (method) {
      case 'card':
        return context.tr("payment_method_card");
      case 'wallet':
        return context.tr("payment_method_wallet");
      case 'cash_at_institution':
        return context.tr("payment_method_cash");
      default:
        return context.tr("booking_result_unknown");
    }
  }

  String _prettyStatus(BuildContext context, String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return context.tr("booking_result_unknown");

    switch (normalized) {
      case 'confirmed':
        return context.tr("status_confirmed");
      case 'success':
        return context.tr("status_success");
      case 'failed':
        return context.tr("status_failed");
      case 'pending_payment':
        return context.tr("status_pending_payment");
      case 'pending':
        return context.tr("status_pending");
      case 'cancelled':
        return context.tr("status_cancelled");
      default:
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
  }

  _ResultPresentation _buildPresentation(
      BuildContext context,
      BookingModel? booking,
      BookingPaymentModel? payment,
      ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (booking == null) {
      return _ResultPresentation(
        title: context.tr("booking_result_not_found_title"),
        message: context.tr("booking_result_not_found_message"),
        icon: Icons.help_outline,
        accent: onSurface,
      );
    }

    final bookingStatus = booking.bookingStatus.toLowerCase();
    final paymentStatus =
    (payment?.paymentStatus ?? booking.paymentStatus).toLowerCase();

    if (bookingStatus == 'confirmed') {
      return _ResultPresentation(
        title: context.tr("booking_result_confirmed_title"),
        message: context.tr("booking_result_confirmed_message"),
        icon: Icons.check_circle_outline,
        accent: Colors.green,
      );
    }

    if (bookingStatus == 'pending_payment' || paymentStatus == 'pending') {
      return _ResultPresentation(
        title: context.tr("booking_result_processing_title"),
        message: context.tr("booking_result_processing_message"),
        icon: Icons.hourglass_top_rounded,
        accent: Colors.orange,
      );
    }

    if (bookingStatus == 'cancelled') {
      return _ResultPresentation(
        title: context.tr("booking_result_cancelled_title"),
        message: context.tr("booking_result_cancelled_message"),
        icon: Icons.remove_circle_outline,
        accent: onSurface,
      );
    }

    return _ResultPresentation(
      title: context.tr("booking_result_failed_title"),
      message: context.tr("booking_result_failed_message"),
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
      title: Text(context.tr("booking_result_title")),
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
                          context.tr("booking_result_load_error"),
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
                              context.tr("booking_result_back_home"),
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
                                label: context.tr("booking_result_label_id"),
                                value: booking.id,
                              ),
                              _ResultRow(
                                label: context.tr("booking_result_label_booking_status"),
                                value: _prettyStatus(context, booking.bookingStatus),
                              ),
                              _ResultRow(
                                label: context.tr("booking_result_label_payment_method"),
                                value: _paymentMethodLabel(context, booking.paymentMethod),
                              ),
                              _ResultRow(
                                label: context.tr("booking_result_label_payment_status"),
                                value: _prettyStatus(
                                  context,
                                  payment?.paymentStatus ?? booking.paymentStatus,
                                ),
                              ),
                              _ResultRow(
                                label: context.tr("booking_result_label_date"),
                                value: booking.requestedDate
                                    .toIso8601String()
                                    .split('T')
                                    .first,
                              ),
                              _ResultRow(
                                label: context.tr("booking_result_label_time"),
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
                            context.tr("booking_result_back_home"),
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