import 'package:flutter/material.dart';

// This widget shows a short summary of the current search and chip filter results.
class InstitutionResultsSummary extends StatelessWidget {
  final int count;
  final String query;
  final String selectedFilter;

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

    String label;

    if (!hasQuery && !hasChipFilter) {
      label = 'Showing $count institution${count == 1 ? '' : 's'}';
    } else if (hasQuery && !hasChipFilter) {
      label = 'Showing $count result${count == 1 ? '' : 's'} for "$query"';
    } else if (!hasQuery && hasChipFilter) {
      label = 'Showing $count institution${count == 1 ? '' : 's'} in $selectedFilter';
    } else {
      label = 'Showing $count result${count == 1 ? '' : 's'} for "$query" in $selectedFilter';
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
