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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
