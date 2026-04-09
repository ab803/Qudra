import 'package:flutter/material.dart';
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
              label: 'All Posts',
              isSelected: selectedTab == 'all',
              onTap: () => onTabSelected('all'),
            ),
            const SizedBox(width: 8),
            FilterChipItem(
              label: 'My Posts',
              isSelected: selectedTab == 'my',
              onTap: () => onTabSelected('my'),
            ),
          ],
        ),
      ),
    );
  }
}