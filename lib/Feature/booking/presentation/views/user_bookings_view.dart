import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/user_bookings_cubit.dart';
import '../../viewmodel/user_bookings_state.dart';
import '../../../feedback/widgets/rate_institution_dialog.dart';



// This screen shows all bookings created by the current signed-in user.
class UserBookingsView extends StatelessWidget {
  const UserBookingsView({super.key});

  // This helper formats the booking date into dd/MM/yyyy.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // This helper maps booking status to a compact label color.
  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value == 'confirmed' || value == 'success') {
      return Colors.green;
    }
    if (value == 'failed') {
      return Colors.red;
    }
    if (value == 'pending_payment' || value == 'pending') {
      return Colors.orange;
    }
    return Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: BlocBuilder<UserBookingsCubit, UserBookingsState>(
          builder: (context, state) {
            if (state is UserBookingsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is UserBookingsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is UserBookingsLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(
                  child: Text('No bookings found yet.'),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // This block shows the institution and service titles.
                          Text(
                            booking.institutionName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.serviceName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // This block shows booking details rows.
                          _InfoRow(
                            label: 'Date',
                            value: _formatDate(booking.requestedDate),
                          ),
                          _InfoRow(
                            label: 'Time',
                            value: booking.requestedTime,
                          ),
                          _InfoRow(
                            label: 'Amount',
                            value: 'EGP ${booking.amount.toStringAsFixed(2)}',
                          ),
                          _InfoRow(
                            label: 'Method',
                            value: booking.paymentMethod,
                          ),
                          const SizedBox(height: 14),

                          // This block shows booking and payment statuses.
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _StatusChip(
                                label: 'Booking: ${booking.bookingStatus}',
                                color: _statusColor(booking.bookingStatus),
                              ),
                              _StatusChip(
                                label: 'Payment: ${booking.paymentStatus}',
                                color: _statusColor(booking.paymentStatus),
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
                                    const SnackBar(
                                      content: Text(
                                        'Institution rating submitted successfully.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Rate Institution',
                                style: TextStyle(
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

// This widget renders a single information row in the booking card.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// This widget renders a compact colored status chip.
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}