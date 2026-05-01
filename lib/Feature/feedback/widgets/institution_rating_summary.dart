import 'package:flutter/material.dart';
// This import enables localized text access using context.tr().
import '../../../core/Services/Localization/translation_extension.dart';
import '../services/feedback_service.dart';

// This widget loads and displays the average rating and reviews count
// for a specific institution using direct Supabase reads.
class InstitutionRatingSummary extends StatefulWidget {
  final String institutionId;
  final bool compact;

  const InstitutionRatingSummary({
    super.key,
    required this.institutionId,
    this.compact = false,
  });

  @override
  State<InstitutionRatingSummary> createState() =>
      _InstitutionRatingSummaryState();
}

class _InstitutionRatingSummaryState extends State<InstitutionRatingSummary> {
  final FeedbackService _feedbackService = FeedbackService();
  late Future<Map<String, dynamic>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    // This block loads the institution rating summary only once
    // when the widget is first created.
    _summaryFuture =
        _feedbackService.getInstitutionRatingSummary(widget.institutionId);
  }

  // This helper builds a localized short or full summary label based on the use case.
  String _buildSummaryLabel(
      BuildContext context, {
        required double average,
        required int count,
      }) {
    if (count == 0) {
      return widget.compact
          ? context.tr('institution_no_ratings')
          : context.tr('institution_no_ratings_yet');
    }

    // This block chooses the localized summary key based on compact mode and count.
    final key = widget.compact
        ? 'institution_rating_summary_compact'
        : (count == 1
        ? 'institution_rating_summary_one'
        : 'institution_rating_summary_many');

    return context
        .tr(key)
        .replaceAll('{average}', average.toStringAsFixed(1))
        .replaceAll('{count}', count.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ],
          );
        }

        final data = snapshot.data ?? {'average': 0.0, 'count': 0};
        final average = (data['average'] as num?)?.toDouble() ?? 0.0;
        final count = (data['count'] as int?) ?? 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: colorScheme.primary,
              size: widget.compact ? 17 : 18,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                // This block shows a localized fallback label when loading the summary fails.
                snapshot.hasError
                    ? (widget.compact
                    ? context.tr('institution_no_ratings')
                    : context.tr('institution_no_ratings_yet'))
                    : _buildSummaryLabel(
                  context,
                  average: average,
                  count: count,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.compact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}