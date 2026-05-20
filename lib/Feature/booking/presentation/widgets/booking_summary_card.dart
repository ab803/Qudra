import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../institution/models/institution_model.dart';
import '../../../institution/models/service_model.dart';

// This widget shows a compact summary of the institution and selected service.
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

  // This helper formats the selected booking date into dd/MM/yyyy.
  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return context.tr("booking_summary_not_selected");
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // This helper converts HH:mm values into a 12-hour display format.
  String _formatTimeTo12Hour(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr("booking_summary_not_selected");
    }

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteText $period';
  }

  // This helper formats the service price or marks it as free.
  String _formatPrice(BuildContext context) {
    if (service.isFree) return context.tr("service_free");
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
          // This block shows the institution name and selected service.
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.05),
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

          // This block shows booking-related summary rows.
          _InfoRow(
            label: context.tr("booking_summary_category"),
            value: service.category,
          ),
          _InfoRow(
            label: context.tr("booking_summary_price"),
            value: _formatPrice(context),
          ),
          _InfoRow(
            label: context.tr("booking_summary_duration"),
            value: '${service.durationMinutes} ${context.tr("minutes_short")}',
          ),
          _InfoRow(
            label: context.tr("booking_summary_date"),
            value: _formatDate(context, requestedDate),
          ),
          _InfoRow(
            label: context.tr("booking_summary_time"),
            // This block renders the selected booking time in a 12-hour user-friendly format.
            value: _formatTimeTo12Hour(context, requestedTime),
          ),
          _InfoRow(
            label: context.tr("booking_summary_notes"),
            value: (notes != null && notes!.trim().isNotEmpty)
                ? notes!.trim()
                : context.tr("booking_summary_no_notes"),
          ),
        ],
      ),
    );
  }
}

// This widget renders a single summary row inside the booking card.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
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
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
