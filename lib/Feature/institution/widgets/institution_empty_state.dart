import 'package:flutter/material.dart';

// This widget renders a friendlier empty state when no institutions match the search or chip filter.
class InstitutionEmptyState extends StatelessWidget {
  final String query;
  final String selectedFilter;
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

    String title;
    String subtitle;

    if (hasQuery && hasChipFilter) {
      title = 'No institutions match your search and filter';
      subtitle =
      'Try a different keyword, choose another category, or clear the current filters.';
    } else if (hasQuery) {
      title = 'No institutions match your search';
      subtitle =
      'Try a different keyword or clear the current search to see all institutions.';
    } else if (hasChipFilter) {
      title = 'No institutions found in $selectedFilter';
      subtitle =
      'Try another category or clear the current filter to see all institutions.';
    } else {
      title = 'No institutions found';
      subtitle = 'Please check again later.';
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
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            if (hasQuery || hasChipFilter) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                // This button clears the active search text and chip filter.
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
                label: const Text(
                  'Clear Filters',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}