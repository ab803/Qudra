import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

class InstitutionResultsSummary extends StatelessWidget {
  final int count;
  final String query;
  final String selectedFilter; // English key

  const InstitutionResultsSummary({
    super.key,
    required this.count,
    required this.query,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = query.isNotEmpty;
    final hasChipFilter = selectedFilter != 'All';
    final isOne = count == 1;

    final localizedFilter = hasChipFilter
        ? context.tr('filter_${selectedFilter.toLowerCase()}')
        : '';

    String label;

    if (!hasQuery && !hasChipFilter) {
      label = context
          .tr(isOne ? 'results_showing_all_one' : 'results_showing_all_many')
          .replaceAll('{count}', '$count');
    } else if (hasQuery && !hasChipFilter) {
      label = context
          .tr(isOne ? 'results_showing_query_one' : 'results_showing_query_many')
          .replaceAll('{count}', '$count')
          .replaceAll('{query}', query);
    } else if (!hasQuery && hasChipFilter) {
      label = context
          .tr(isOne ? 'results_showing_filter_one' : 'results_showing_filter_many')
          .replaceAll('{count}', '$count')
          .replaceAll('{filter}', localizedFilter);
    } else {
      label = context
          .tr(isOne ? 'results_showing_both_one' : 'results_showing_both_many')
          .replaceAll('{count}', '$count')
          .replaceAll('{query}', query)
          .replaceAll('{filter}', localizedFilter);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}