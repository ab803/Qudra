import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';

class EmergencyDirectServicesRow extends StatelessWidget {
  const EmergencyDirectServicesRow({
    super.key,
    required this.onPolicePressed,
    required this.onAmbulancePressed,
    required this.onFirePressed,
  });

  final VoidCallback onPolicePressed;
  final VoidCallback onAmbulancePressed;
  final VoidCallback onFirePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // This title is localized for the direct emergency services section.
          context.tr('emergency_direct_services'),
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ServiceCard(
                // This title is localized for the police service.
                title: context.tr('emergency_service_police'),
                subtitle: '122',
                icon: Icons.local_police_rounded,
                accentColor: const Color(0xFF2563EB),
                onTap: onPolicePressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                // This title is localized for the ambulance service.
                title: context.tr('emergency_service_ambulance'),
                subtitle: '123',
                icon: Icons.medical_services_rounded,
                accentColor: const Color(0xFF16A34A),
                onTap: onAmbulancePressed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ServiceCard(
                // This title is localized for the fire service.
                title: context.tr('emergency_service_fire'),
                subtitle: '180',
                icon: Icons.local_fire_department_rounded,
                accentColor: const Color(0xFFF97316),
                onTap: onFirePressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
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
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.18 : 0.10,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                // This icon now correctly uses the service-specific icon.
                icon,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.68),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}