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

  // This helper returns a cleaned availability notes value for display.
  String? _normalizedAvailabilityNotes() {
    final value = service.availabilityNotes?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final availabilityNotes = _normalizedAvailabilityNotes();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          // This block renders the service name and category.
          Text(
            service.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            service.category,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // This block renders the optional service description.
          if (service.description != null &&
              service.description!.trim().isNotEmpty) ...[
            Text(
              service.description!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.72),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // This block renders the availability notes when the institution provides them.
          if (availabilityNotes != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.16 : 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Availability Notes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          availabilityNotes,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Book Now',
                style: theme.textTheme.labelLarge?.copyWith(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color bgColor;
    Color textColor;
    Border? border;

    if (dark) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      border = null;
    } else if (light) {
      bgColor = colorScheme.primary.withOpacity(
        theme.brightness == Brightness.dark ? 0.16 : 0.08,
      );
      textColor = colorScheme.primary;
      border = Border.all(
        color: colorScheme.primary.withOpacity(0.18),
      );
    } else {
      bgColor = colorScheme.onSurface.withOpacity(
        theme.brightness == Brightness.dark ? 0.10 : 0.05,
      );
      textColor = colorScheme.onSurface.withOpacity(0.85);
      border = Border.all(color: theme.dividerColor);
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
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1,
        ),
      ),
    );
  }
}