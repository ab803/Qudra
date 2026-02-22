import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

class A11yTipCard extends StatelessWidget {
  final String title;
  final String body;
  final List<String> tags;
  final bool bookmarked;

  const A11yTipCard({
    super.key,
    required this.title,
    required this.body,
    this.tags = const [],
    this.bookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + علامة حفظ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    color: Appcolors.primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: Appcolors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // الوصف
          Text(
            body,
            style: AppTextStyles.body.copyWith(
              color: Appcolors.secondaryColor,
              height: 1.35,
              fontSize: 13.5,
            ),
          ),

          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((t) => _TagPill(t)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Appcolors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Appcolors.primaryColor,
          height: 1.0,
        ),
      ),
    );
  }
}