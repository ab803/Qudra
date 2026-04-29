import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';

class BookingSummaryCard extends StatelessWidget {
  final InstitutionModel institution;
  final InstitutionServiceModel service;
  final DateTime? requestedDate;
  final String? requestedTime;
  final String? notes;

  const BookingSummaryCard({
    super.key,
    required this.institution,
    required this.service,
    this.requestedDate,
    this.requestedTime,
    this.notes,
  });

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return context.tr('booking_summary_not_selected');
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatPrice(BuildContext context) {
    if (service.isFree) return context.tr('service_free');
    return 'EGP ${service.price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.22 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface
                      .withOpacity(isDark ? 0.08 : 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.business, color: colorScheme.onSurface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      institution.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: context.tr('booking_summary_category'),
            value: service.category,
          ),
          _InfoRow(
            label: context.tr('booking_summary_price'),
            value: _formatPrice(context),
          ),
          _InfoRow(
            label: context.tr('booking_summary_duration'),
            value: '${service.durationMinutes} min',
          ),
          _InfoRow(
            label: context.tr('booking_summary_date'),
            value: _formatDate(context, requestedDate),
          ),
          _InfoRow(
            label: context.tr('booking_summary_time'),
            value: requestedTime ?? context.tr('booking_summary_not_selected'),
          ),
          _InfoRow(
            label: context.tr('booking_summary_notes'),
            value: (notes != null && notes!.trim().isNotEmpty)
                ? notes!.trim()
                : context.tr('booking_summary_no_notes'),
          ),
        ],
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
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}