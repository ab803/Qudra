import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../widgets/booking_payment_method_tile.dart';
import '../widgets/booking_summary_card.dart';

// This screen lets the user choose the payment method after entering booking details.
class BookingPaymentMethodView extends StatefulWidget {
  final InstitutionModel institution;
  final InstitutionServiceModel service;
  final DateTime requestedDate;
  final String requestedTime;
  final String? notes;

  const BookingPaymentMethodView({
    super.key,
    required this.institution,
    required this.service,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
  });

  @override
  State<BookingPaymentMethodView> createState() =>
      _BookingPaymentMethodViewState();
}

class _BookingPaymentMethodViewState extends State<BookingPaymentMethodView> {
  String _selectedMethod = 'card';

  // This helper builds the route payload _shared between the method-specific booking screens.
  Map<String, dynamic> _buildExtra() {
    return {
      'institution': widget.institution,
      'service': widget.service,
      'requestedDate': widget.requestedDate,
      'requestedTime': widget.requestedTime,
      'notes': widget.notes,
    };
  }

  // This helper opens the correct payment screen for the selected booking payment method.
  void _continue() {
    switch (_selectedMethod) {
      case 'card':
        context.push('/booking/card', extra: _buildExtra());
        break;
      case 'wallet':
        context.push('/booking/wallet', extra: _buildExtra());
        break;
      case 'cash_at_institution':
        context.push('/booking/cash', extra: _buildExtra());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment Method',
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
              // This block shows the current booking summary above payment selection.
              BookingSummaryCard(
                institution: widget.institution,
                service: widget.service,
                requestedDate: widget.requestedDate,
                requestedTime: widget.requestedTime,
                notes: widget.notes,
              ),
              const SizedBox(height: 20),

              // This block shows the payment method title.
              const Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),

              // This block renders the card option.
              BookingPaymentMethodTile(
                icon: Icons.credit_card_outlined,
                title: 'Card',
                subtitle: 'Pay securely using Paymob test checkout.',
                selected: _selectedMethod == 'card',
                onTap: () {
                  setState(() {
                    _selectedMethod = 'card';
                  });
                },
              ),
              const SizedBox(height: 12),

              // This block renders the wallet option.
              BookingPaymentMethodTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                subtitle: 'Pay using a supported mobile wallet via Paymob.',
                selected: _selectedMethod == 'wallet',
                onTap: () {
                  setState(() {
                    _selectedMethod = 'wallet';
                  });
                },
              ),
              const SizedBox(height: 12),

              // This block renders the cash option.
              BookingPaymentMethodTile(
                icon: Icons.payments_outlined,
                title: 'Cash at Institution',
                subtitle: 'Confirm the booking now and pay at the institution.',
                selected: _selectedMethod == 'cash_at_institution',
                onTap: () {
                  setState(() {
                    _selectedMethod = 'cash_at_institution';
                  });
                },
              ),
              const SizedBox(height: 24),

              // This block opens the selected payment method flow.
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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