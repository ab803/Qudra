import 'package:flutter/material.dart';

// This delegate keeps the institutions filter bar pinned while scrolling.
class InstitutionStickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  InstitutionStickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 68;

  @override
  double get minExtent => 68;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}