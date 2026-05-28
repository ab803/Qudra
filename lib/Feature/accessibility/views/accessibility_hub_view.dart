import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/Services/Localization/translation_extension.dart';
import '../../../core/Services/voiceAssistant/VoiceFab.dart';
import '../../../core/Styles/AppColors.dart';
import '../viewModel/tips_rights_cubit.dart';

class AccessibilityHubView extends StatefulWidget {
  const AccessibilityHubView({super.key});

  @override
  State<AccessibilityHubView> createState() => _AccessibilityHubViewState();
}

// This enum controls the selected awareness content type filter in the user app.
enum _AwarenessContentFilter {
  all,
  tip,
  right,
  article,
  video,
}

class _AccessibilityHubViewState extends State<AccessibilityHubView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // This field stores the selected disability category filter.
  String _selectedDisabilityFilter = 'all';

  // This field stores the selected awareness content type filter.
  _AwarenessContentFilter _selectedContentFilter = _AwarenessContentFilter.all;

  static const List<_CategoryMeta> _categories = [
    _CategoryMeta(
      label: 'category_visual',
      type: 'visual',
      icon: Icons.visibility_outlined,
      subtitle: 'subtitle_visual',
      color: Color(0xFF4A90D9),
    ),
    _CategoryMeta(
      label: 'category_hearing',
      type: 'hearing',
      icon: Icons.hearing_outlined,
      subtitle: 'subtitle_hearing',
      color: Color(0xFF7B68EE),
    ),
    _CategoryMeta(
      label: 'category_physical',
      type: 'physical',
      icon: Icons.accessibility_new_outlined,
      subtitle: 'subtitle_physical',
      color: Color(0xFF50C878),
    ),
    _CategoryMeta(
      label: 'category_cognitive',
      type: 'cognitive',
      icon: Icons.psychology_outlined,
      subtitle: 'subtitle_cognitive',
      color: Color(0xFFF5A623),
    ),
    _CategoryMeta(
      label: 'category_other',
      type: 'other',
      icon: Icons.more_horiz,
      subtitle: 'subtitle_other',
      color: Color(0xFFFF6B6B),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // This block loads all dynamic awareness resources from Supabase.
    context.read<RightstipsCubit>().loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // This helper maps a content filter to its matching model type.
  AwarenessContentType? _matchingContentType(_AwarenessContentFilter filter) {
    switch (filter) {
      case _AwarenessContentFilter.all:
        return null;
      case _AwarenessContentFilter.tip:
        return AwarenessContentType.tip;
      case _AwarenessContentFilter.right:
        return AwarenessContentType.right;
      case _AwarenessContentFilter.article:
        return AwarenessContentType.article;
      case _AwarenessContentFilter.video:
        return AwarenessContentType.video;
    }
  }

  // This helper returns a localized label key for each content filter.
  String _contentFilterLabelKey(_AwarenessContentFilter filter) {
    switch (filter) {
      case _AwarenessContentFilter.all:
        return 'content_type_all';
      case _AwarenessContentFilter.tip:
        return 'content_type_tips';
      case _AwarenessContentFilter.right:
        return 'content_type_rights';
      case _AwarenessContentFilter.article:
        return 'content_type_articles';
      case _AwarenessContentFilter.video:
        return 'content_type_videos';
    }
  }

  // This helper returns an icon for each content filter.
  IconData _contentFilterIcon(_AwarenessContentFilter filter) {
    switch (filter) {
      case _AwarenessContentFilter.all:
        return Icons.dashboard_customize_outlined;
      case _AwarenessContentFilter.tip:
        return Icons.lightbulb_outline;
      case _AwarenessContentFilter.right:
        return Icons.gavel_rounded;
      case _AwarenessContentFilter.article:
        return Icons.article_outlined;
      case _AwarenessContentFilter.video:
        return Icons.play_circle_outline;
    }
  }

  // This helper returns a color for each awareness content type.
  Color _contentTypeColor(AwarenessContentType type) {
    switch (type) {
      case AwarenessContentType.tip:
        return const Color(0xFFF59E0B);
      case AwarenessContentType.right:
        return const Color(0xFF3B82F6);
      case AwarenessContentType.article:
        return const Color(0xFF10B981);
      case AwarenessContentType.video:
        return const Color(0xFFEF4444);
    }
  }

  // This helper returns an icon for each awareness content type.
  IconData _contentTypeIcon(AwarenessContentType type) {
    switch (type) {
      case AwarenessContentType.tip:
        return Icons.lightbulb_outline;
      case AwarenessContentType.right:
        return Icons.gavel_rounded;
      case AwarenessContentType.article:
        return Icons.article_outlined;
      case AwarenessContentType.video:
        return Icons.play_circle_outline;
    }
  }

  // This helper returns a localized label key for each awareness content type.
  String _contentTypeLabelKey(AwarenessContentType type) {
    switch (type) {
      case AwarenessContentType.tip:
        return 'content_type_tip';
      case AwarenessContentType.right:
        return 'content_type_right';
      case AwarenessContentType.article:
        return 'content_type_article';
      case AwarenessContentType.video:
        return 'content_type_video';
    }
  }

  // This helper checks whether a resource matches the selected disability category.
  bool _matchesDisabilityFilter(tipsRightsModel tip) {
    if (_selectedDisabilityFilter == 'all') return true;

    final types = tip.disabilityType
        .map((type) => type.trim().toLowerCase())
        .where((type) => type.isNotEmpty)
        .toList();

    if (types.isEmpty) return true;

    return types.contains(_selectedDisabilityFilter.toLowerCase()) ||
        types.contains('all') ||
        types.contains('other');
  }

  // This helper checks whether a resource matches the selected content type.
  bool _matchesContentFilter(tipsRightsModel tip) {
    final matchingType = _matchingContentType(_selectedContentFilter);

    if (matchingType == null) return true;

    return tip.contentType == matchingType;
  }

  // This helper checks whether a resource matches the search query.
  bool _matchesSearch(tipsRightsModel tip) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return true;

    final searchableText = [
      tip.title,
      tip.description,
      tip.contentType.value,
      ...tip.disabilityType,
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  // This helper applies all current filters to the resources list.
  List<tipsRightsModel> _filteredResources(List<tipsRightsModel> allTips) {
    final filtered = allTips.where((tip) {
      return _matchesDisabilityFilter(tip) &&
          _matchesContentFilter(tip) &&
          _matchesSearch(tip);
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // This helper chooses a stable daily tip based on today's date.
  tipsRightsModel? _pickDailyTip(List<tipsRightsModel> allTips) {
    final dailyCandidates = allTips.where((tip) => tip.isDailyTip).toList();

    if (dailyCandidates.isEmpty) return null;

    dailyCandidates.sort((a, b) => a.id.compareTo(b.id));

    final now = DateTime.now();

    // This index makes the selected Daily Tip stable during the same day.
    final daySeed = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );

    return dailyCandidates[daySeed % dailyCandidates.length];
  }

  // This method opens a video or article URL in an external app/browser.
  Future<void> _openExternalUrl(BuildContext context, String? rawUrl) async {
    final url = rawUrl?.trim();

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('resource_url_missing')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme || uri.host.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('resource_url_invalid')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('resource_url_open_error')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // This method opens a bottom sheet with full resource details.
  Future<void> _showResourceDetails(
      BuildContext context,
      tipsRightsModel resource,
      ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _contentTypeColor(resource.contentType);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This drag handle indicates the sheet can be dismissed.
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // This block renders the resource type badge.
                  _ResourceBadge(
                    label: context.tr(_contentTypeLabelKey(resource.contentType)),
                    icon: _contentTypeIcon(resource.contentType),
                    color: accentColor,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    resource.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    resource.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.78),
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (resource.isDailyTip)
                        _ResourceBadge(
                          label: context.tr('daily_tip'),
                          icon: Icons.today_outlined,
                          color: const Color(0xFFA855F7),
                        ),
                      if (resource.isFeatured)
                        _ResourceBadge(
                          label: context.tr('featured'),
                          icon: Icons.star_border_rounded,
                          color: const Color(0xFF14B8A6),
                        ),
                      if (resource.readTimeMinutes != null)
                        _NeutralPill(
                          icon: Icons.timer_outlined,
                          label:
                          '${resource.readTimeMinutes} ${context.tr('minutes_short')}',
                        ),
                      ...resource.disabilityType.map(
                            (type) => _NeutralPill(
                          icon: Icons.accessibility_new_rounded,
                          label: type,
                        ),
                      ),
                    ],
                  ),

                  if (resource.contentType == AwarenessContentType.video ||
                      resource.contentType == AwarenessContentType.article) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openExternalUrl(context, resource.mediaUrl),
                        icon: Icon(
                          resource.contentType == AwarenessContentType.video
                              ? Icons.play_circle_outline
                              : Icons.open_in_new_rounded,
                        ),
                        label: Text(
                          resource.contentType == AwarenessContentType.video
                              ? context.tr('watch_video')
                              : context.tr('open_article'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const VoiceFAB(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeroHeader(),
          _buildSearchBar(),
          _buildContentTypeFilters(),
          _buildDisabilityFilterChips(),
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

                if (state is RightstipsActionSuccess) {
                  final colorScheme = Theme.of(context).colorScheme;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: TextStyle(color: colorScheme.onPrimary),
                      ),
                      backgroundColor: colorScheme.primary,
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
        context.tr('accessibility_awareness_hub'),
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
              color: theme.colorScheme.primary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  // This widget renders a short intro for the awareness hub.
  Widget _buildHeroHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(
                theme.brightness == Brightness.dark ? 0.08 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.16 : 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('awareness_hub_title'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('awareness_hub_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.70),
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            borderSide: BorderSide(
              color: Appcolors.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // This widget renders the content type filters row.
  Widget _buildContentTypeFilters() {
    final filters = _AwarenessContentFilter.values;

    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          return _buildContentChip(filter);
        }).toList(),
      ),
    );
  }

  // This widget renders one content type filter chip.
  Widget _buildContentChip(_AwarenessContentFilter filter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _selectedContentFilter == filter;

    return GestureDetector(
      onTap: () => setState(() => _selectedContentFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _contentFilterIcon(filter),
              size: 16,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withOpacity(0.68),
            ),
            const SizedBox(width: 6),
            Text(
              context.tr(_contentFilterLabelKey(filter)),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withOpacity(0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This widget renders the disability filter chips row.
  Widget _buildDisabilityFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _buildDisabilityChip(
            label: context.tr('filter_all'),
            value: 'all',
          ),
          ..._categories.map(
                (category) => _buildDisabilityChip(
              label: context.tr(category.label),
              value: category.type,
              icon: category.icon,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabilityChip({
    required String label,
    required String value,
    IconData? icon,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = _selectedDisabilityFilter == value;
    final accentColor = color ?? colorScheme.primary;

    return GestureDetector(
      onTap: () => setState(() => _selectedDisabilityFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withOpacity(
            theme.brightness == Brightness.dark ? 0.20 : 0.12,
          )
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? accentColor
                    : colorScheme.onSurface.withOpacity(0.68),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? accentColor
                    : colorScheme.onSurface.withOpacity(0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<tipsRightsModel> allTips) {
    final dailyTip = _pickDailyTip(allTips);
    final filteredResources = _filteredResources(allTips);

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => context.read<RightstipsCubit>().loadAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (dailyTip != null) ...[
            _DailyTipCard(
              tip: dailyTip,
              accentColor: _contentTypeColor(dailyTip.contentType),
              typeIcon: _contentTypeIcon(dailyTip.contentType),
              typeLabel: context.tr(_contentTypeLabelKey(dailyTip.contentType)),
              onTap: () => _showResourceDetails(context, dailyTip),
            ),
            const SizedBox(height: 18),
          ],

          _buildResultsSummary(filteredResources.length),

          const SizedBox(height: 14),

          if (filteredResources.isEmpty)
            _buildEmptyState()
          else
            ...filteredResources.map(
                  (resource) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AwarenessResourceCard(
                  resource: resource,
                  accentColor: _contentTypeColor(resource.contentType),
                  typeIcon: _contentTypeIcon(resource.contentType),
                  typeLabel:
                  context.tr(_contentTypeLabelKey(resource.contentType)),
                  onTap: () => _showResourceDetails(context, resource),
                  onOpenUrl: () => _openExternalUrl(context, resource.mediaUrl),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // This widget shows how many resources match the current filters.
  Widget _buildResultsSummary(int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            color: colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context
                  .tr('awareness_results_count')
                  .replaceAll('{count}', count.toString()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.76),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This widget renders an empty state when no resource matches the active filters.
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: colorScheme.onSurface.withOpacity(0.34),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('no_awareness_resources_found'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('no_awareness_resources_found_desc'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.68),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        ],
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
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
              size: 36,
            ),
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

// This model stores the local disability category metadata.
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

// This widget renders the Daily Tip section at the top of the awareness hub.
class _DailyTipCard extends StatelessWidget {
  final tipsRightsModel tip;
  final Color accentColor;
  final IconData typeIcon;
  final String typeLabel;
  final VoidCallback onTap;

  const _DailyTipCard({
    required this.tip,
    required this.accentColor,
    required this.typeIcon,
    required this.typeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.18 : 0.10,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.today_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ResourceBadge(
                      label: context.tr('daily_tip'),
                      icon: typeIcon,
                      color: accentColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tip.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tip.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.72),
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This widget renders a dynamic awareness resource card.
class _AwarenessResourceCard extends StatelessWidget {
  final tipsRightsModel resource;
  final Color accentColor;
  final IconData typeIcon;
  final String typeLabel;
  final VoidCallback onTap;
  final VoidCallback onOpenUrl;

  const _AwarenessResourceCard({
    required this.resource,
    required this.accentColor,
    required this.typeIcon,
    required this.typeLabel,
    required this.onTap,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool hasExternalAction =
        resource.contentType == AwarenessContentType.video ||
            resource.contentType == AwarenessContentType.article;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.10,                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  typeIcon,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ResourceBadge(
                          label: typeLabel,
                          icon: typeIcon,
                          color: accentColor,
                        ),
                        if (resource.isFeatured)
                          _ResourceBadge(
                            label: context.tr('featured'),
                            icon: Icons.star_border_rounded,
                            color: const Color(0xFF14B8A6),
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      resource.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      resource.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.70),
                        fontSize: 13.2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (resource.readTimeMinutes != null)
                          _NeutralPill(
                            icon: Icons.timer_outlined,
                            label:
                            '${resource.readTimeMinutes} ${context.tr('minutes_short')}',
                          ),
                        ...resource.disabilityType.take(3).map(
                              (type) => _NeutralPill(
                            icon: Icons.accessibility_new_rounded,
                            label: type,
                          ),
                        ),
                      ],
                    ),
                    if (hasExternalAction) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: onOpenUrl,
                          icon: Icon(
                            resource.contentType == AwarenessContentType.video
                                ? Icons.play_circle_outline
                                : Icons.open_in_new_rounded,
                            size: 18,
                          ),
                          label: Text(
                            resource.contentType == AwarenessContentType.video
                                ? context.tr('watch_video')
                                : context.tr('open_article'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurface.withOpacity(0.38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This widget renders a colored badge for content type and resource flags.
class _ResourceBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ResourceBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(
          theme.brightness == Brightness.dark ? 0.18 : 0.10,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// This widget renders neutral metadata pills for disability, read time, and more.
class _NeutralPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NeutralPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(
          theme.brightness == Brightness.dark ? 0.10 : 0.05,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: colorScheme.onSurface.withOpacity(0.62),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.72),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}