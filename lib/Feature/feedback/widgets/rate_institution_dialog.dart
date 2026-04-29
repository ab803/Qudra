import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../services/feedback_service.dart';

class RateInstitutionDialog extends StatefulWidget {
  final String institutionId;
  final String institutionName;

  const RateInstitutionDialog({
    super.key,
    required this.institutionId,
    required this.institutionName,
  });

  @override
  State<RateInstitutionDialog> createState() => _RateInstitutionDialogState();
}

class _RateInstitutionDialogState extends State<RateInstitutionDialog> {
  final FeedbackService _feedbackService = FeedbackService();
  int _selectedRating = 0;
  bool _isLoadingInitialRating = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingRating();
  }

  Future<void> _loadExistingRating() async {
    try {
      final existingRating =
      await _feedbackService.getMyInstitutionRating(widget.institutionId);

      if (!mounted) return;

      setState(() {
        _selectedRating = existingRating ?? 0;
        _isLoadingInitialRating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitialRating = false;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('please_select_rating')),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _feedbackService.submitOrUpdateInstitutionRating(
        institutionId: widget.institutionId,
        rating: _selectedRating,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStarRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= _selectedRating;

        return IconButton(
          onPressed: _isSubmitting
              ? null
              : () {
            setState(() {
              _selectedRating = starNumber;
            });
          },
          iconSize: 38,
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            color: isSelected
                ? colorScheme.primary
                : theme.textTheme.bodySmall?.color,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: theme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _isLoadingInitialRating
            ? const SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Title
            Text(
              context.tr('rate_institution'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),

            /// Institution name
            Text(
              widget.institutionName,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            /// Stars
            _buildStarRow(context),

            const SizedBox(height: 16),

            /// Rating text
            Text(
              _selectedRating == 0
                  ? context.tr('select_your_rating')
                  : context.tr(
                'your_rating',
              ).replaceAll('{}', '$_selectedRating'),
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            /// Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      context.tr('cancel'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                        : Text(
                      _selectedRating == 0
                          ? context.tr('submit')
                          : context.tr('save_rating'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}