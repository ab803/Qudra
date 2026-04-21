import 'package:flutter/material.dart';

import '../models/service_model.dart';

// This widget renders a service card inside institution details and exposes a booking action.
class ServiceTile extends StatelessWidget {
  final InstitutionServiceModel service;
  final VoidCallback? onBookNow;

  const ServiceTile({
    super.key,
    required this.service,
    this.onBookNow,
  });

  // This helper formats the service price label.
  String _formatPrice() {
    if (service.isFree) return 'Free';
    return 'EGP ${service.price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          // This block renders the service name and category.
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.category,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // This block renders the optional service description.
          if (service.description != null &&
              service.description!.trim().isNotEmpty) ...[
            Text(
              service.description!.trim(),
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // This block renders service metadata chips.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TagChip(text: _formatPrice(), dark: true),
              _TagChip(text: '${service.durationMinutes} min'),
              _TagChip(text: service.locationMode.replaceAll('_', ' ')),
              _TagChip(text: service.bookingType.replaceAll('_', ' ')),
              ...service.supportedDisabilities.map(
                    (item) => _TagChip(text: item, light: true),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // This block renders the booking action at the bottom of the service card.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onBookNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This widget renders a reusable service metadata chip.
class _TagChip extends StatelessWidget {
  final String text;
  final bool light;
  final bool dark;

  const _TagChip({
    required this.text,
    this.light = false,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    if (dark) {
      bgColor = Colors.black;
      textColor = Colors.white;
      border = null;
    } else if (light) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade800;
      border = Border.all(color: Colors.grey.shade300);
    } else {
      bgColor = const Color(0xFFF5F5F5);
      textColor = Colors.black87;
      border = Border.all(color: Colors.black.withOpacity(0.05));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: border,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}