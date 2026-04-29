import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';
import '../widgets/booking_payment_method_tile.dart';
import '../widgets/booking_summary_card.dart';

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

  Map<String, dynamic> _buildExtra() => {
    'institution': widget.institution,
    'service': widget.service,
    'requestedDate': widget.requestedDate,
    'requestedTime': widget.requestedTime,
    'notes': widget.notes,
  };

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('booking_payment_method_title')),
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
              Text(
                context.tr('booking_choose_method'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              BookingPaymentMethodTile(
                icon: Icons.credit_card_outlined,
                title: context.tr('booking_method_card_title'),
                subtitle: context.tr('booking_method_card_subtitle'),
                selected: _selectedMethod == 'card',
                onTap: () => setState(() => _selectedMethod = 'card'),
              ),
              const SizedBox(height: 12),
              BookingPaymentMethodTile(
                icon: Icons.account_balance_wallet_outlined,
                title: context.tr('booking_method_wallet_title'),
                subtitle: context.tr('booking_method_wallet_subtitle'),
                selected: _selectedMethod == 'wallet',
                onTap: () => setState(() => _selectedMethod = 'wallet'),
              ),
              const SizedBox(height: 12),
              BookingPaymentMethodTile(
                icon: Icons.payments_outlined,
                title: context.tr('booking_method_cash_title'),
                subtitle: context.tr('booking_method_cash_subtitle'),
                selected: _selectedMethod == 'cash_at_institution',
                onTap: () =>
                    setState(() => _selectedMethod = 'cash_at_institution'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    context.tr('booking_continue'),
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