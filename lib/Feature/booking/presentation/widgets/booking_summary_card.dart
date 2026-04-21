import 'package:flutter/material.dart';

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
  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  // This helper formats the service price or marks it as free.
  String _formatPrice() {
    if (service.isFree) return 'Free';
    return 'EGP ${service.price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      institution.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
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
          _InfoRow(label: 'Category', value: service.category),
          _InfoRow(label: 'Price', value: _formatPrice()),
          _InfoRow(
            label: 'Duration',
            value: '${service.durationMinutes} min',
          ),
          _InfoRow(
            label: 'Date',
            value: _formatDate(requestedDate),
          ),
          _InfoRow(
            label: 'Time',
            value: requestedTime ?? 'Not selected',
          ),
          _InfoRow(
            label: 'Notes',
            value: (notes != null && notes!.trim().isNotEmpty)
                ? notes!.trim()
                : 'No additional notes',
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}