import 'package:flutter/material.dart';
import '../../../core/Services/Localization/translation_extension.dart';
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
  String _formatPrice(BuildContext context) {
    if (service.isFree) return context.tr("service_free");
    return 'EGP ${service.price.toStringAsFixed(2)}';
  }

  // This helper formats the working days value for display.
  String? _formattedWorkingDays() {
    if (service.workingDays.isEmpty) return null;
    return service.workingDays.join(', ');
  }

  // This helper normalizes service working time values into HH:mm text.
  String? _normalizeTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  // This helper converts HH:mm values into a 12-hour display format.
  String? _formatTimeTo12Hour(String? value) {
    final normalized = _normalizeTime(value);
    if (normalized == null) return null;

    final parts = normalized.split(':');
    if (parts.length < 2) return normalized;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return normalized;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteText $period';
  }

  // This helper builds the final working hours summary for display.
  String? _formattedWorkingHours() {
    final start = _formatTimeTo12Hour(service.workingStartTime);
    final end = _formatTimeTo12Hour(service.workingEndTime);

    if (start == null || end == null) return null;

    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workingDays = _formattedWorkingDays();
    final workingHours = _formattedWorkingHours();

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

          // This block renders the service working schedule summary.
          if (workingDays != null || workingHours != null) ...[
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
                        // This text shows the localized working hours title.
                        Text(
                          context.tr("service_working_hours"),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (workingDays != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            workingDays,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                        if (workingHours != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            workingHours,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.45,
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
              _TagChip(text: _formatPrice(context), dark: true),
              _TagChip(
                text: '${service.durationMinutes} ${context.tr("minutes_short")}',
              ),
              _TagChip(text: service.locationMode.replaceAll('_', ' ')),
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
                context.tr("service_book_now"),
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