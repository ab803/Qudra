import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_cubit.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_state.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_top_header.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_title_section.dart';
import 'package:qudra_0/Feature/institution/widgets/institutionCard.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_empty_state.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_filter_bar.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_results_summary.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_search_bar.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_sticky_filter_delegate.dart';
import 'package:qudra_0/core/Styles/AppColors.dart';

class InstitutionView extends StatefulWidget {
  final String initialQuery;

  const InstitutionView({
    Key? key,
    this.initialQuery = '',
  }) : super(key: key);

  @override
  State<InstitutionView> createState() => _InstitutionViewState();
}

class _InstitutionViewState extends State<InstitutionView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDisabilityFilter = 'All';

  // This listener rebuilds the page while the user types in the search field.
  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // This method applies local text filtering on the loaded institutions list.
  List<InstitutionModel> _applySearchFilter(
      List<InstitutionModel> institutions,
      ) {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return institutions;
    }

    return institutions.where((institution) {
      final searchableText = [
        institution.name,
        institution.institutionType,
        institution.address ?? '',
        institution.location,
      ].join(' ').toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  // This method maps the visible chip label to the actual disability value used in services.
  String _mapChipToDisabilityValue(String chipLabel) {
    switch (chipLabel) {
      case 'Mobility':
        return 'Physical';
      case 'Vision':
        return 'Visual';
      case 'Hearing':
        return 'Hearing';
      default:
        return 'All';
    }
  }

  // This method applies the selected disability chip filter using the loaded services map.
  List<InstitutionModel> _applyDisabilityFilter(
      List<InstitutionModel> institutions,
      Map<String, List<String>> supportedDisabilitiesByInstitution,
      ) {
    final mappedFilter = _mapChipToDisabilityValue(_selectedDisabilityFilter);

    if (mappedFilter == 'All') {
      return institutions;
    }

    return institutions.where((institution) {
      final supportedDisabilities =
          supportedDisabilitiesByInstitution[institution.id] ?? const [];

      return supportedDisabilities.any(
            (item) => item.toLowerCase() == mappedFilter.toLowerCase(),
      );
    }).toList();
  }

  // This method combines text search filtering with the selected disability chip filter.
  List<InstitutionModel> _applyInstitutionFilters(
      List<InstitutionModel> institutions,
      Map<String, List<String>> supportedDisabilitiesByInstitution,
      ) {
    final searchFilteredInstitutions = _applySearchFilter(institutions);

    return _applyDisabilityFilter(
      searchFilteredInstitutions,
      supportedDisabilitiesByInstitution,
    );
  }

  @override
  void initState() {
    super.initState();

    // This block fills the institutions search field with the incoming home query.
    _searchController.text = widget.initialQuery;
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InstitutionCubit>().loadInstitutions();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const InstitutionTopHeader(),
                    const SizedBox(height: 24),
                    const InstitutionTitleSection(),
                    const SizedBox(height: 16),
                    InstitutionSearchBar(
                      controller: _searchController,
                      onClear: () {
                        _searchController.clear();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: InstitutionStickyFilterDelegate(
                child: Container(
                  color: const Color(0xFFF7F8FA),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 14),
                  child: InstitutionFilterBar(
                    selectedFilter: _selectedDisabilityFilter,
                    onFilterSelected: (label) {
                      setState(() {
                        _selectedDisabilityFilter = label;
                      });
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<InstitutionCubit, InstitutionState>(
                builder: (context, state) {
                  if (state is InstitutionsLoaded) {
                    final filteredInstitutions = _applyInstitutionFilters(
                      state.institutions,
                      state.supportedDisabilitiesByInstitution,
                    );

                    return InstitutionResultsSummary(
                      count: filteredInstitutions.length,
                      query: _searchController.text.trim(),
                      selectedFilter: _selectedDisabilityFilter,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            BlocBuilder<InstitutionCubit, InstitutionState>(
              builder: (context, state) {
                if (state is InstitutionLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is InstitutionError) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.errorMessage)),
                  );
                }

                if (state is InstitutionsLoaded) {
                  // This block applies both text search and chip filtering on the loaded institutions list.
                  final filteredInstitutions = _applyInstitutionFilters(
                    state.institutions,
                    state.supportedDisabilitiesByInstitution,
                  );

                  if (filteredInstitutions.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: InstitutionEmptyState(
                        query: _searchController.text.trim(),
                        selectedFilter: _selectedDisabilityFilter,
                        onClearFilters: () {
                          setState(() {
                            _searchController.clear();
                            _selectedDisabilityFilter = 'All';
                          });
                        },
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final institution = filteredInstitutions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InstitutionCard(
                              institution: institution,
                              onViewDetails: () {
                                context.push('/institution/${institution.id}');
                              },
                            ),
                          );
                        },
                        childCount: filteredInstitutions.length,
                      ),
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
