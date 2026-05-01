import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/core/Services/Localization/translation_extension.dart';
import '../../../../core/Styles/AppTextsyles.dart';

// This screen provides searchable and filterable guidance that matches the real app flows.
class AppGuidelinesView extends StatefulWidget {
  const AppGuidelinesView({super.key});

  @override
  State<AppGuidelinesView> createState() => _AppGuidelinesViewState();
}

class _AppGuidelinesViewState extends State<AppGuidelinesView> {
  // This controller stores the current help search query.
  final TextEditingController _searchController = TextEditingController();

  // This field stores the currently selected topic chip.
  String _selectedTopic = 'all_topics';

  // This list defines the topics that appear in the horizontal filter chips.
  static const List<String> _topics = <String>[
    'all_topics',
    'accessibility_topic',
    'chatbot_topic',
    'health_topic',
    'safety_topic',
    'institutions_topic',
  ];

  // This list contains the real guidelines shown inside the help screen.
  static const List<_GuidelineItem> _guidelines = <_GuidelineItem>[
    _GuidelineItem(
      categoryKey: 'chatbot_topic',
      icon: Icons.smart_toy_outlined,
      titleKey: 'guideline_chatbot_title',
      descriptionKey: 'guideline_chatbot_description',
      actionLabelKey: 'open_chatbot',
      route: '/chat',
    ),
    _GuidelineItem(
      categoryKey: 'health_topic',
      icon: Icons.notifications_active_outlined,
      titleKey: 'guideline_reminders_title',
      descriptionKey: 'guideline_reminders_description',
      actionLabelKey: 'open_reminders',
      route: '/reminders',
    ),
    _GuidelineItem(
      categoryKey: 'accessibility_topic',
      icon: Icons.menu_book_outlined,
      titleKey: 'guideline_accessibility_title',
      descriptionKey: 'guideline_accessibility_description',
      actionLabelKey: 'open_accessibility_hub',
      route: '/accessibility',
    ),
    _GuidelineItem(
      categoryKey: 'safety_topic',
      icon: Icons.emergency_outlined,
      titleKey: 'guideline_emergency_title',
      descriptionKey: 'guideline_emergency_description',
      actionLabelKey: 'open_emergency',
      route: '/emergency-entry',
    ),
    _GuidelineItem(
      categoryKey: 'institutions_topic',
      icon: Icons.business_outlined,
      titleKey: 'guideline_institutions_title',
      descriptionKey: 'guideline_institutions_description',
      actionLabelKey: 'open_institutions',
      route: '/institution',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // This getter returns the visible guidelines after applying topic and text filters.
  List<_GuidelineItem> _filteredGuidelines(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    return _guidelines.where((item) {
      final matchesTopic =
          _selectedTopic == 'all_topics' || item.categoryKey == _selectedTopic;

      final searchableText = [
        context.tr(item.titleKey),
        context.tr(item.descriptionKey),
        context.tr(item.categoryKey),
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchableText.contains(query);
      return matchesTopic && matchesQuery;
    }).toList();
  }

  // This helper clears the current search text and rebuilds the list.
  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  // This helper opens the feedback screen from the support CTA.
  void _openFeedback() {
    context.push('/feedback');
  }

  String _replaceParams(String text, Map<String, String> params) {
    var result = text;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredGuidelines = _filteredGuidelines(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          context.tr("app_guidelines_title"),
          style: AppTextStyles.title.copyWith(
            fontSize: 18,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: theme.dividerColor,
              thickness: 1,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This top section introduces the help experience and current app guidance scope.
                  _buildIntroSection(context),
                  const SizedBox(height: 24),
                  // Search Bar
                  // This search field filters guideline cards by title, description, and category.
                  _buildSearchField(context),
                  const SizedBox(height: 20),
                  // Filter Chips
                  // This chips row lets the user switch between guideline topics.
                  _buildTopicChips(context),
                  const SizedBox(height: 20),
                  // This summary row shows the current filtering result count.
                  _buildResultsSummary(context, filteredGuidelines.length),
                  const SizedBox(height: 18),
                  // Guideline Cards
                  // This section renders the currently filtered guideline cards.
                  if (filteredGuidelines.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...filteredGuidelines.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGuidelineCard(
                          context,
                          item: item,
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  // Still need help section
                  // This support card sends the user to the feedback screen.
                  _buildSupportSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This widget builds the screen heading and descriptive intro copy.
  Widget _buildIntroSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr("how_can_we_help"),
          style: AppTextStyles.title.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr("app_guidelines_intro"),
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
            height: 1.55,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  // This widget builds the interactive search input used by the guidelines list.
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.12 : 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: context.tr("search_help"),
          hintStyle: AppTextStyles.body.copyWith(
            color: theme.inputDecorationTheme.hintStyle?.color,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.inputDecorationTheme.hintStyle?.color,
          ),
          suffixIcon: _searchController.text.trim().isEmpty
              ? null
              : IconButton(
            onPressed: _clearSearch,
            icon: Icon(
              Icons.close,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // This widget builds the horizontal list of interactive topic chips.
  Widget _buildTopicChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _topics.map((topic) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildFilterChip(
              context,
              topic,
              _selectedTopic == topic,
            ),
          );
        }).toList(),
      ),
    );
  }

  // This widget renders one topic chip and updates the selected topic when tapped.
  Widget _buildFilterChip(
      BuildContext context,
      String label,
      bool isSelected,
      ) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopic = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(
                isSelected
                    ? (theme.brightness == Brightness.dark ? 0.14 : 0.06)
                    : 0,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          context.tr(label),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  // This widget shows the number of visible guidelines after filtering.
  Widget _buildResultsSummary(BuildContext context, int count) {
    final theme = Theme.of(context);
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasTopicFilter = _selectedTopic != 'all_topics';

    String label;
    if (hasSearch && hasTopicFilter) {
      label = count == 1
          ? _replaceParams(
        context.tr("guidelines_showing_both_one"),
        {
          "count": count.toString(),
          "query": _searchController.text.trim(),
          "topic": context.tr(_selectedTopic),
        },
      )
          : _replaceParams(
        context.tr("guidelines_showing_both_many"),
        {
          "count": count.toString(),
          "query": _searchController.text.trim(),
          "topic": context.tr(_selectedTopic),
        },
      );
    } else if (hasSearch) {
      label = count == 1
          ? _replaceParams(
        context.tr("guidelines_showing_query_one"),
        {
          "count": count.toString(),
          "query": _searchController.text.trim(),
        },
      )
          : _replaceParams(
        context.tr("guidelines_showing_query_many"),
        {
          "count": count.toString(),
          "query": _searchController.text.trim(),
        },
      );
    } else if (hasTopicFilter) {
      label = count == 1
          ? _replaceParams(
        context.tr("guidelines_showing_topic_one"),
        {
          "count": count.toString(),
          "topic": context.tr(_selectedTopic),
        },
      )
          : _replaceParams(
        context.tr("guidelines_showing_topic_many"),
        {
          "count": count.toString(),
          "topic": context.tr(_selectedTopic),
        },
      );
    } else {
      label = count == 1
          ? _replaceParams(
        context.tr("guidelines_showing_all_one"),
        {
          "count": count.toString(),
        },
      )
          : _replaceParams(
        context.tr("guidelines_showing_all_many"),
        {
          "count": count.toString(),
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This widget renders a polished guideline card with category, content, and action button.
  Widget _buildGuidelineCard(
      BuildContext context, {
        required _GuidelineItem item,
      }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.12 : 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Icon(
                  item.icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(
                          theme.brightness == Brightness.dark ? 0.16 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.tr(item.categoryKey),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(item.titleKey),
                      style: AppTextStyles.title.copyWith(
                        fontSize: 17,
                        color: theme.textTheme.titleLarge?.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.tr(item.descriptionKey),
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              height: 1.6,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(item.route),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                Icons.arrow_forward_rounded,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                context.tr(item.actionLabelKey),
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This widget appears when no guideline matches the current search and filter state.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
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
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr("no_guidelines_found"),
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr("no_guidelines_found_desc"),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTopic = 'all_topics';
                _searchController.clear();
              });
            },
            child: Text(
              context.tr("clear_filters"),
              style: AppTextStyles.body.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This widget renders the bottom support CTA that opens the feedback screen.
  Widget _buildSupportSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.12 : 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            context.tr("still_need_help"),
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr("guidelines_support_description"),
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openFeedback,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                context.tr("contact_support"),
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// This model stores one guideline item and its optional navigation action.
class _GuidelineItem {
  final String categoryKey;
  final IconData icon;
  final String titleKey;
  final String descriptionKey;
  final String actionLabelKey;
  final String route;

  const _GuidelineItem({
    required this.categoryKey,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.actionLabelKey,
    required this.route,
  });
}
