import 'package:flutter/material.dart';
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

  // This helper builds a short or full summary label based on the use case.
  String _buildSummaryLabel({
    required double average,
    required int count,
  }) {
    if (count == 0) {
      return widget.compact ? 'No ratings' : 'No ratings yet';
    }

    if (widget.compact) {
      return '${average.toStringAsFixed(1)} • $count reviews';
    }

    return '${average.toStringAsFixed(1)} • $count review${count == 1 ? '' : 's'}';
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
                snapshot.hasError
                    ? (widget.compact ? 'No ratings' : 'No ratings yet')
                    : _buildSummaryLabel(
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