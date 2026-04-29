import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

class InstitutionEmptyState extends StatelessWidget {
  final String query;
  final String selectedFilter; // English key e.g. 'All', 'Mobility'
  final VoidCallback onClearFilters;

  const InstitutionEmptyState({
    super.key,
    required this.query,
    required this.selectedFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasQuery = query.isNotEmpty;
    final hasChipFilter = selectedFilter != 'All';

    // Localized display label for the active chip filter.
    final localizedFilter = hasChipFilter
        ? context.tr('filter_${selectedFilter.toLowerCase()}')
        : '';

    String title;
    String subtitle;

    if (hasQuery && hasChipFilter) {
      title    = context.tr('empty_no_match_search_filter');
      subtitle = context.tr('empty_no_match_search_filter_subtitle');
    } else if (hasQuery) {
      title    = context.tr('empty_no_match_search');
      subtitle = context.tr('empty_no_match_search_subtitle');
    } else if (hasChipFilter) {
      title    = context.tr('empty_no_match_filter').replaceAll('{filter}', localizedFilter);
      subtitle = context.tr('empty_no_match_filter_subtitle');
    } else {
      title    = context.tr('empty_no_institutions');
      subtitle = context.tr('empty_no_institutions_subtitle');
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            if (hasQuery || hasChipFilter) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onClearFilters,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  context.tr('clear_filters'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}