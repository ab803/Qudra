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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasQuery = query.isNotEmpty;
    final hasChipFilter = selectedFilter != 'All';

    String label;

    if (!hasQuery && !hasChipFilter) {
      label = 'Showing $count institution${count == 1 ? '' : 's'}';
    } else if (hasQuery && !hasChipFilter) {
      label = 'Showing $count result${count == 1 ? '' : 's'} for "$query"';
    } else if (!hasQuery && hasChipFilter) {
      label =
      'Showing $count institution${count == 1 ? '' : 's'} in $selectedFilter';
    } else {
      label =
      'Showing $count result${count == 1 ? '' : 's'} for "$query" in $selectedFilter';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(
                  isDark ? 0.16 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.88),
                ),
              ),
              if (hasChipFilter)
                _SummaryBadge(
                  label: selectedFilter,
                  color: colorScheme.primary,
                ),
              if (hasQuery)
                _SummaryBadge(
                  label: query,
                  color: colorScheme.onSurface,
                  outlined: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const _SummaryBadge({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: outlined ? theme.dividerColor : color.withOpacity(0.22),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: outlined ? theme.colorScheme.onSurface : color,
          height: 1.0,
        ),
      ),
    );
  }
}