import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

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

  String _replaceParams(String text, Map<String, String> params) {
    var result = text;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  String _translateFilterLabel(BuildContext context, String filter) {
    switch (filter) {
      case 'Mobility':
        return context.tr("filter_mobility");
      case 'Vision':
        return context.tr("filter_vision");
      case 'Hearing':
        return context.tr("filter_hearing");
      case 'Cognitive':
        return context.tr("filter_cognitive");
      case 'Other':
        return context.tr("filter_other");
      default:
        return context.tr("filter_all");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasQuery = query.isNotEmpty;
    final hasChipFilter = selectedFilter != 'All';

    String title;
    String subtitle;

    if (hasQuery && hasChipFilter) {
      title = context.tr("empty_no_match_search_filter");
      subtitle = context.tr("empty_no_match_search_filter_subtitle");
    } else if (hasQuery) {
      title = context.tr("empty_no_match_search");
      subtitle = context.tr("empty_no_match_search_subtitle");
    } else if (hasChipFilter) {
      final localizedFilter = _translateFilterLabel(context, selectedFilter);
      title = _replaceParams(
        context.tr("empty_no_match_filter"),
        {"filter": localizedFilter},
      );
      subtitle = context.tr("empty_no_match_filter_subtitle");
    } else {
      title = context.tr("empty_no_institutions");
      subtitle = context.tr("empty_no_institutions_subtitle");
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
                label: Text(
                  context.tr("clear_filters"),
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