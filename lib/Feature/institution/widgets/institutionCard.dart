import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feedback/widgets/institution_rating_summary.dart';
import '../models/institution_model.dart';

class InstitutionCard extends StatelessWidget {
  final InstitutionModel institution;
  final VoidCallback onViewDetails;

  // This flag switches the card between full-page mode and compact home recommendation mode.
  final bool isCompact;

  const InstitutionCard({
    super.key,
    required this.institution,
    required this.onViewDetails,
    this.isCompact = false,
  });

  // This method opens the institution location link in an external maps app.
  Future<void> _openLocationLink(BuildContext context) async {
    final uri = Uri.parse(institution.location);
    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the location link.'),
        ),
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
        borderRadius: BorderRadius.circular(isCompact ? 22 : 24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.26 : 0.08),
            blurRadius: isCompact ? 12 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 10 : 12),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business,
                  color: colorScheme.onSurface,
                  size: isCompact ? 22 : 24,
                ),
              ),
              SizedBox(width: isCompact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This block limits long institution names based on the active card mode.
                    Text(
                      institution.name,
                      maxLines: isCompact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: isCompact ? 16.5 : 18,
                        fontWeight: FontWeight.bold,
                        height: isCompact ? 1.18 : 1.28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institution.institutionType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: isCompact ? 12.5 : 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),

          // Address / location
          if (institution.address != null && institution.address!.isNotEmpty)
          // This block trims the address more aggressively in compact mode to fit the horizontal home layout.
            Text(
              institution.address!,
              maxLines: isCompact ? 1 : 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isCompact ? 13 : 14,
                height: isCompact ? 1.25 : 1.4,
              ),
            ),
          if (institution.address != null && institution.address!.isNotEmpty)
            SizedBox(height: isCompact ? 8 : 3),

          // This block renders a lightweight location action to keep the card compact.
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openLocationLink(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: isCompact ? 15 : 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Open in Maps',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isCompact ? 12.5 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: isCompact ? 14 : 15,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isCompact ? 12 : 14),

          // This block switches the footer layout to a stacked compact footer for home cards.
          if (isCompact) ...[
            InstitutionRatingSummary(
              institutionId: institution.id,
              compact: true,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View Details',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Footer row: rating summary on the left and details button on the right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InstitutionRatingSummary(
                      institutionId: institution.id,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}