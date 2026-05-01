import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    final hasQuery = query.isNotEmpty;
    final hasChipFilter = selectedFilter != 'All';

    String label;
    final localizedFilter = _translateFilterLabel(context, selectedFilter);

    if (!hasQuery && !hasChipFilter) {
      label = count == 1
          ? _replaceParams(
        context.tr("results_showing_all_one"),
        {"count": count.toString()},
      )
          : _replaceParams(
        context.tr("results_showing_all_many"),
        {"count": count.toString()},
      );
    } else if (hasQuery && !hasChipFilter) {
      label = count == 1
          ? _replaceParams(
        context.tr("results_showing_query_one"),
        {
          "count": count.toString(),
          "query": query,
        },
      )
          : _replaceParams(
        context.tr("results_showing_query_many"),
        {
          "count": count.toString(),
          "query": query,
        },
      );
    } else if (!hasQuery && hasChipFilter) {
      label = count == 1
          ? _replaceParams(
        context.tr("results_showing_filter_one"),
        {
          "count": count.toString(),
          "filter": localizedFilter,
        },
      )
          : _replaceParams(
        context.tr("results_showing_filter_many"),
        {
          "count": count.toString(),
          "filter": localizedFilter,
        },
      );
    } else {
      label = count == 1
          ? _replaceParams(
        context.tr("results_showing_both_one"),
        {
          "count": count.toString(),
          "query": query,
          "filter": localizedFilter,
        },
      )
          : _replaceParams(
        context.tr("results_showing_both_many"),
        {
          "count": count.toString(),
          "query": query,
          "filter": localizedFilter,
        },
      );
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
                  label: localizedFilter,
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