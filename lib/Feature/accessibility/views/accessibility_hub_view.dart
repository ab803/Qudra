import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
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

  /// Labels and subtitles store translation keys — resolved with context.tr()
  /// at display time so the const list is preserved.
  static const List<_CategoryMeta> _categories = [
    _CategoryMeta(
      labelKey: 'category_visual',
      subtitleKey: 'subtitle_visual',
      type: 'visual',
      icon: Icons.visibility_outlined,
      color: Color(0xFF4A90D9),
    ),
    _CategoryMeta(
      labelKey: 'category_hearing',
      subtitleKey: 'subtitle_hearing',
      type: 'hearing',
      icon: Icons.hearing_outlined,
      color: Color(0xFF7B68EE),
    ),
    _CategoryMeta(
      labelKey: 'category_physical',
      subtitleKey: 'subtitle_physical',
      type: 'physical',
      icon: Icons.accessibility_new_outlined,
      color: Color(0xFF50C878),
    ),
    _CategoryMeta(
      labelKey: 'category_cognitive',
      subtitleKey: 'subtitle_cognitive',
      type: 'cognitive',
      icon: Icons.psychology_outlined,
      color: Color(0xFFF5A623),
    ),
    _CategoryMeta(
      labelKey: 'category_other',
      subtitleKey: 'subtitle_other',
      type: 'other',
      icon: Icons.more_horiz,
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
          (tip.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (tip.description
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<RightstipsCubit, RightstipsState>(
              listener: (context, state) {
                if (state is RightstipsError) {
                  final colorScheme = Theme.of(context).colorScheme;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: TextStyle(color: colorScheme.onError),
                      ),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RightstipsLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        context.tr('accessibility_hub'),
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: theme.cardColor,
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: context.tr('search_hint_a11y'),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: onSurface.withOpacity(0.38),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: onSurface.withOpacity(0.38),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              size: 18,
              color: onSurface.withOpacity(0.38),
            ),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor),
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
          _buildChip(label: context.tr('filter_all'), value: 'all'),
          _buildChip(label: context.tr('filter_popular'), value: 'popular'),
          ..._categories.map(
                (c) => _buildChip(label: context.tr(c.labelKey), value: c.type),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required String label, required String value}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<tipsRightsModel> allTips) {
    if (_selectedFilter != 'all' && _selectedFilter != 'popular') {
      final meta =
      _categories.firstWhere((c) => c.type == _selectedFilter);
      final filtered = _filterTips(allTips, _selectedFilter);
      return _buildSingleCategory(context, meta, filtered);
    }

    if (_selectedFilter == 'popular') {
      final sorted = [...allTips]
        ..sort((a, b) =>
            (b.createdAt ?? DateTime(0))
                .compareTo(a.createdAt ?? DateTime(0)));
      final searched = sorted
          .where((t) =>
      _searchQuery.isEmpty ||
          (t.title
              ?.toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
              false))
          .toList();
      return _buildFlatList(context, searched);
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(meta.icon, color: meta.color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr(meta.labelKey),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${tips.length} ${context.tr('items_label')}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: onSurface.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.tr(meta.subtitleKey),
          style: theme.textTheme.bodySmall?.copyWith(
            color: onSurface.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        if (tips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              context.tr('no_resources'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withOpacity(0.5),
                fontSize: 14,
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
    );
  }

  Widget _buildSingleCategory(
      BuildContext context,
      _CategoryMeta meta,
      List<tipsRightsModel> tips,
      ) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(meta.icon, color: meta.color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr(meta.labelKey),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${tips.length} ${context.tr('items_label')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(meta.subtitleKey),
            style: theme.textTheme.bodySmall?.copyWith(
              color: onSurface.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          if (tips.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  context.tr('no_resources_category'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
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
    final theme = Theme.of(context);

    if (tips.isEmpty) {
      return Center(
        child: Text(
          context.tr('no_resources_found'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.38),
            fontSize: 14,
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 36),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<RightstipsCubit>().loadAll(),
              child: Text(
                context.tr('retry'),
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models & Widgets
// ---------------------------------------------------------------------------

class _CategoryMeta {
  /// Translation key for the display label (e.g. 'category_visual').
  final String labelKey;

  /// Translation key for the subtitle (e.g. 'subtitle_visual').
  final String subtitleKey;

  final String type;
  final IconData icon;
  final Color color;

  const _CategoryMeta({
    required this.labelKey,
    required this.subtitleKey,
    required this.type,
    required this.icon,
    required this.color,
  });
}

class _TipCard extends StatelessWidget {
  final tipsRightsModel tip;
  final Color accentColor;

  const _TipCard({required this.tip, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.08 : 0.04,
            ),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onSurface.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: onSurface.withOpacity(0.4),
            size: 20,
          ),
        ],
      ),
    );
  }
}