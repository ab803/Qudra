import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../feedback/widgets/institution_rating_summary.dart';
import '../models/institution_model.dart';

class InstitutionCard extends StatelessWidget {
  final InstitutionModel institution;
  final VoidCallback onViewDetails;

  const InstitutionCard({
    super.key,
    required this.institution,
    required this.onViewDetails,
  });

  Future<void> _openLocationLink(BuildContext context) async {
    final uri = Uri.parse(institution.location);
    final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('institution_open_location_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.30 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface
                      .withOpacity(isDark ? 0.08 : 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.business,
                    color: colorScheme.onSurface, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      institution.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institution.institutionType,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (institution.address != null &&
              institution.address!.isNotEmpty)
            Text(
              institution.address!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontSize: 14, height: 1.4),
            ),
          const SizedBox(height: 3),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openLocationLink(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('institution_open_in_maps'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.open_in_new_rounded,
                      size: 15,
                      color: theme.textTheme.bodySmall?.color),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InstitutionRatingSummary(
                      institutionId: institution.id),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('institution_view_details'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}