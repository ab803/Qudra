import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import '../../../core/Styles/AppColors.dart';
import '../viewModel/tips_rights_cubit.dart';

class AccessibilityHubView extends StatefulWidget {
  const AccessibilityHubView({super.key});

  @override
  State<AccessibilityHubView> createState() => _AccessibilityHubViewState();
}

class _AccessibilityHubViewState extends State<AccessibilityHubView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  static const List<_CategoryMeta> _categories = [
    _CategoryMeta(
      label: 'Visual',
      type: 'visual',
      icon: Icons.visibility_outlined,
      subtitle: 'Blindness, Low Vision, Color Blindness',
      color: Color(0xFF4A90D9),
    ),
    _CategoryMeta(
      label: 'Hearing',
      type: 'hearing',
      icon: Icons.hearing_outlined,
      subtitle: 'Deafness, Hard of Hearing, Sign Language',
      color: Color(0xFF7B68EE),
    ),
    _CategoryMeta(
      label: 'Physical',
      type: 'physical',
      icon: Icons.accessibility_new_outlined,
      subtitle: 'Mobility, Motor Disability, Wheelchair',
      color: Color(0xFF50C878),
    ),
    _CategoryMeta(
      label: 'Cognitive',
      type: 'cognitive',
      icon: Icons.psychology_outlined,
      subtitle: 'Learning Disabilities, Neurodiversity',
      color: Color(0xFFF5A623),
    ),
    _CategoryMeta(
      label: 'Other',
      type: 'other',
      icon: Icons.more_horiz,
      subtitle: 'Speech, Invisible Disabilities',
      color: Color(0xFFFF6B6B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<RightstipsCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<tipsRightsModel> _filterTips(List<tipsRightsModel> tips, String type) {
    return tips.where((tip) {
      final types = tip.disabilityType ?? [];
      final matchesType = type == 'all' || types.contains(type);
      final matchesSearch = _searchQuery.isEmpty ||
          (tip.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (tip.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<RightstipsCubit, RightstipsState>(
              listener: (context, state) {
                if (state is RightstipsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RightstipsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1C1C1E)),
                  );
                }
                if (state is RightstipsError) {
                  return _buildErrorView(context, state.message);
                }
                if (state is RightstipsLoaded) {
                  return _buildContent(context, state.tips);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF2F2F7),
      elevation: 0,
      title: const Text(
        'Accessibility Hub',
        style: TextStyle(
          color: Color(0xFF1C1C1E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE5E5EA),
            radius: 16,
            child: Icon(
              Icons.accessibility_new,
              color: Appcolors.primaryColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search rights, tips, resources...',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
          prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black38),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.black38),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Appcolors.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(label: 'All', value: 'all'),
          _buildChip(label: 'Popular', value: 'popular'),
          ..._categories.map((c) => _buildChip(label: c.label, value: c.type)),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required String value}) {
    final selected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF1C1C1E)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<tipsRightsModel> allTips) {
    // Single category
    if (_selectedFilter != 'all' && _selectedFilter != 'popular') {
      final meta = _categories.firstWhere((c) => c.type == _selectedFilter);
      final filtered = _filterTips(allTips, _selectedFilter);
      return _buildSingleCategory(context, meta, filtered);
    }

    // Popular: sorted by newest
    if (_selectedFilter == 'popular') {
      final sorted = [...allTips]
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      final searched = sorted.where((t) =>
      _searchQuery.isEmpty ||
          (t.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false)).toList();
      return _buildFlatList(context, searched);
    }

    // All: grouped by category
    return RefreshIndicator(
      color: const Color(0xFF1C1C1E),
      onRefresh: () => context.read<RightstipsCubit>().loadAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _categories.map((meta) {
            final tips = _filterTips(allTips, meta.type);
            return _buildCategoryBlock(context, meta, tips);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryBlock(
      BuildContext context,
      _CategoryMeta meta,
      List<tipsRightsModel> tips,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Section header
        Row(
          children: [
            Icon(meta.icon, color: const Color(0xFF1C1C1E), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                meta.label,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${tips.length} items',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          meta.subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (tips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
            ),
            child: Text(
              'No resources yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TipCard(tip: tips[i], accentColor: meta.color),
          ),
      ],
    );
  }

  Widget _buildSingleCategory(
      BuildContext context,
      _CategoryMeta meta,
      List<tipsRightsModel> tips,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(meta.icon, color: const Color(0xFF1C1C1E), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meta.label,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${tips.length} items',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            meta.subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (tips.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No resources in this category',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  _TipCard(tip: tips[i], accentColor: meta.color),
            ),
        ],
      ),
    );
  }

  Widget _buildFlatList(BuildContext context, List<tipsRightsModel> tips) {
    if (tips.isEmpty) {
      return const Center(
        child: Text(
          'No resources found',
          style: TextStyle(color: Colors.black38, fontSize: 14),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: tips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _TipCard(
        tip: tips[i],
        accentColor: const Color(0xFFF5A623),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<RightstipsCubit>().loadAll(),
              child: const Text(
                'Retry',
                style: TextStyle(color: Color(0xFF1C1C1E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models & Widgets ─────────────────────────────────────────────────────────

class _CategoryMeta {
  final String label;
  final String type;
  final IconData icon;
  final String subtitle;
  final Color color;

  const _CategoryMeta({
    required this.label,
    required this.type,
    required this.icon,
    required this.subtitle,
    required this.color,
  });
}

class _TipCard extends StatelessWidget {
  final tipsRightsModel tip;
  final Color accentColor;

  const _TipCard({required this.tip, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tip.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tip.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}