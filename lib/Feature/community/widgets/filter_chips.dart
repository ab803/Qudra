import 'package:flutter/material.dart';
import 'filter_chip_item.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            FilterChipItem(label: 'All Posts', isSelected: true),
            SizedBox(width: 8),
            FilterChipItem(label: 'Success Stories'),
            SizedBox(width: 8),
            FilterChipItem(label: 'Daily Tips'),
          ],
        ),
      ),
    );
  }
}