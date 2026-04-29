import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../viewmodel/user_bookings_cubit.dart';
import '../../viewmodel/user_bookings_state.dart';
import '../../../feedback/widgets/rate_institution_dialog.dart';

class UserBookingsView extends StatelessWidget {
  const UserBookingsView({super.key});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _localizePaymentMethod(BuildContext context, String method) {
    switch (method.toLowerCase()) {
      case 'wallet': return context.tr('payment_method_wallet');
      case 'card':   return context.tr('payment_method_card');
      case 'cash':   return context.tr('payment_method_cash');
      default:       return method;
    }
  }
  Color _statusColor(BuildContext context, String status) {
    final value = status.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;
    if (value == 'confirmed' || value == 'success') return Colors.green;
    if (value == 'failed') return colorScheme.error;
    if (value == 'pending_payment' || value == 'pending') return Colors.orange;
    return colorScheme.onSurface.withOpacity(0.7);
  }

  // Maps raw DB status values to localized display labels.
  String _localizeStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return context.tr('status_confirmed');
      case 'success':   return context.tr('status_success');
      case 'failed':    return context.tr('status_failed');
      case 'pending_payment': return context.tr('status_pending_payment');
      case 'pending':   return context.tr('status_pending');
      default:          return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_bookings')),
      ),
      body: SafeArea(
        child: BlocBuilder<UserBookingsCubit, UserBookingsState>(
          builder: (context, state) {
            if (state is UserBookingsLoading) {
              return Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              );
            }

            if (state is UserBookingsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              );
            }

            if (state is UserBookingsLoaded) {
              if (state.bookings.isEmpty) {
                return Center(
                  child: Text(
                    context.tr('no_bookings_found'),
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<UserBookingsCubit>().loadCurrentUserBookings(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = state.bookings[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(
                              theme.brightness == Brightness.dark ? 0.08 : 0.04,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.institutionName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.serviceName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            label: context.tr('booking_label_date'),
                            value: _formatDate(booking.requestedDate),
                          ),
                          _InfoRow(
                            label: context.tr('booking_label_time'),
                            value: booking.requestedTime,
                          ),
                          _InfoRow(
                            label: context.tr('booking_label_amount'),
                            value: 'EGP ${booking.amount.toStringAsFixed(2)}',
                          ),
                          _InfoRow(
                            label: context.tr('booking_label_method'),
                            value: _localizePaymentMethod(context, booking.paymentMethod),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusChip(
                                label:
                                '${context.tr('booking_status_prefix')}: ${_localizeStatus(context, booking.bookingStatus)}',
                                color: _statusColor(context, booking.bookingStatus),
                              ),
                              _StatusChip(
                                label:
                                '${context.tr('payment_status_prefix')}: ${_localizeStatus(context, booking.paymentStatus)}',
                                color: _statusColor(context, booking.paymentStatus),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: () async {
                                final didSubmit = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => RateInstitutionDialog(
                                    institutionId: booking.institutionId,
                                    institutionName: booking.institutionName,
                                  ),
                                );
                                if (didSubmit == true && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr('rating_submitted_success'),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                context.tr('rate_institution'),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}