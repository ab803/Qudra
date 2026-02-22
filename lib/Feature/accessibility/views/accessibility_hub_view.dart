import 'package:flutter/material.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';
import 'package:qudra_0/core/Styles/AppTextsyles.dart';

import '../widgets/a11y_search_bar.dart';
import '../widgets/a11y_segment_filter.dart';
import '../widgets/a11y_section_header.dart';
import '../widgets/a11y_tip_card.dart';
import '../widgets/a11y_quick_win_card.dart';

class AccessibilityHubView extends StatelessWidget {
  const AccessibilityHubView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Appcolors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Accessibility Hub',
          style: AppTextStyles.subtitle.copyWith(
            color: Appcolors.primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Appcolors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: const [
            // Search bar
            A11ySearchBar(hintText: 'Search rights and tips'),

            SizedBox(height: 14),

            // Segment filter (Visual selected)
            A11ySegmentFilter(),

            SizedBox(height: 18),

            // Section: Rights & Tips
            A11ySectionHeader(
              label: 'Rights & Tips',
              icon: Icons.settings_suggest_outlined,
            ),

            SizedBox(height: 12),

            // Tip cards
            A11yTipCard(
              title: 'High Contrast Mode Support',
              body:
              'Ensure all text has a contrast ratio of at least 4.5:1 against its background to accommodate users with low vision.',
              tags: ['WCAG 2.1 AA', 'PRIORITY 1'],
              bookmarked: true,
            ),
            SizedBox(height: 12),

            A11yTipCard(
              title: 'Scalable Typography',
              body:
              'Use relative units (rem/em) instead of fixed pixels to allow the UI to scale with system font settings.',
              tags: ['READABILITY'],
            ),
            SizedBox(height: 12),

            A11yTipCard(
              title: 'Alt Text for Non-Text Content',
              body:
              'Provide meaningful alternative text for all functional images so screen readers can interpret them for blind users.',
              tags: ['SCREEN READER'],
            ),

            SizedBox(height: 22),

            // Section: Quick Wins
            A11ySectionHeader(
              label: 'Quick Wins',
              icon: Icons.bolt_outlined,
            ),
            SizedBox(height: 12),

            // Row of quick wins (two cards)
            _QuickWinsRow(),
          ],
        ),
      ),
    );
  }
}

// صف كروت الـ Quick Wins (UI ثابت)
class _QuickWinsRow extends StatelessWidget {
  const _QuickWinsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: A11yQuickWinCard(
            icon: Icons.touch_app_outlined,
            title: 'Target Sizes',
            subtitle: 'Min 44x44 points for touch targets.',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: A11yQuickWinCard(
            icon: Icons.palette_outlined,
            title: 'Color Blindness',
            subtitle: 'Don’t use color as the only signifier.',
          ),
        ),
      ],
    );
  }
}