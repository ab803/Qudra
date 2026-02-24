import 'package:flutter/material.dart';
import 'package:qudra_0/Feature/institution/widgets/dummyData.dart';
import 'package:qudra_0/Feature/institution/widgets/institutionCard.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class InstitutionView extends StatelessWidget {
  const InstitutionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor, // Sourced from your existing imports
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildTopHeader(),
                        const SizedBox(height: 24),
                        _buildTitleAndToggle(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyFilterDelegate(
                    child: Container(
                      color: const Color(0xFFF7F8FA),
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildFilters(),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: InstitutionCard(
                            data: dummyData[index],
                          ),
                        );
                      },
                      childCount: dummyData.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80), // Padding for bottom nav
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'Q',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Qudra',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Icon(Icons.account_circle, size: 32, color: Color(0xFF1E232C)),
      ],
    );
  }

  Widget _buildTitleAndToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Support Centers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.format_list_bulleted, size: 16),
                    SizedBox(width: 4),
                    Text('List', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: const [
                    Icon(Icons.map_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Map', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'Search institutions, services...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.tune, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('All', isSelected: true),
          const SizedBox(width: 10),
          _buildFilterChip('Mobility', icon: Icons.accessible_forward, iconColor: Colors.blue),
          const SizedBox(width: 10),
          _buildFilterChip('Vision', icon: Icons.visibility, iconColor: Colors.orange),
          const SizedBox(width: 10),
          _buildFilterChip('Hearing', icon: Icons.hearing, iconColor: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Helper Delegate for Sticky Headers
// -------------------------------------------------------------
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}