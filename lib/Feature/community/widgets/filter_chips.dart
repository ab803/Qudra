import 'package:flutter/material.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import 'filter_chip_item.dart';

class FilterChips extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  const FilterChips({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChipItem(
              label: context.tr('all_posts'),
              isSelected: selectedTab == 'all',
              onTap: () => onTabSelected('all'),
            ),
            const SizedBox(width: 8),
            FilterChipItem(
              label: context.tr('my_posts'),
              isSelected: selectedTab == 'my',
              onTap: () => onTabSelected('my'),
            ),
          ],
        ),
      ),
    );
  }
}