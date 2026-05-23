import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_empty_state.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_filter_bar.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_results_summary.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_search_bar.dart';

import 'unit/Test_helpers.dart';

// This test harness mimics the live search rebuild behavior used in InstitutionView.
class _InstitutionIntegrationHarness extends StatefulWidget {
  const _InstitutionIntegrationHarness({
    required this.institutions,
    required this.disabilitiesByInstitution,
  });

  final List<InstitutionModel> institutions;
  final Map<String, List<String>> disabilitiesByInstitution;

  @override
  State<_InstitutionIntegrationHarness> createState() =>
      _InstitutionIntegrationHarnessState();
}

class _InstitutionIntegrationHarnessState
    extends State<_InstitutionIntegrationHarness> {
  late final TextEditingController _controller;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // This listener rebuilds the screen whenever the search text changes.
    _controller.addListener(() {
      if (!mounted) return;
      setState(() {});

});}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// This helper maps chip labels to the actual disability values.
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

// This helper applies both search and disability filters.
List<InstitutionModel> _applyFilters() {
  final query = _controller.text.trim().toLowerCase();

  var filtered = widget.institutions.where((institution) {
    final searchableText = [
      institution.name,
      institution.institutionType,
      institution.address ?? '',
      institution.location,
    ].join(' ').toLowerCase();

    return query.isEmpty || searchableText.contains(query);
  }).toList();

  final mappedFilter = _mapChipToDisabilityValue(_selectedFilter);

  if (mappedFilter != 'All') {
    filtered = filtered.where((institution) {
      final supported =
          widget.disabilitiesByInstitution[institution.id] ?? const [];
      return supported.any(
            (item) => item.toLowerCase() == mappedFilter.toLowerCase(),
      );
    }).toList();
  }

  return filtered;
}

@override
Widget build(BuildContext context) {
  final filteredInstitutions = _applyFilters();

  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // This search bar updates results through the controller listener above.
      InstitutionSearchBar(
        controller: _controller,
        onClear: () {
          setState(() {
            _controller.clear();
          });
        },
      ),
      const SizedBox(height: 16),

      // This filter bar updates the selected disability chip.
      InstitutionFilterBar(
        selectedFilter: _selectedFilter,
        onFilterSelected: (value) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
      const SizedBox(height: 16),

      // This summary reflects the current filtered result set.
      InstitutionResultsSummary(
        count: filteredInstitutions.length,
        query: _controller.text.trim(),
        selectedFilter: _selectedFilter,
      ),
      const SizedBox(height: 16),

      // This block shows either results or the empty state.
      if (filteredInstitutions.isEmpty)
        InstitutionEmptyState(
          query: _controller.text.trim(),
          selectedFilter: _selectedFilter,
          onClearFilters: () {
            setState(() {
              _controller.clear();
              _selectedFilter = 'All';
            });
          },
        )
      else
        ...filteredInstitutions.map(
              (institution) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(institution.name),
          ),
        ),
    ],
  );
}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration › Institution', () {
    // This test verifies the full search and filter flow for the institution discovery widgets.
    testWidgets('user can search, filter, and clear institution results',
            (tester) async {
          final institutions = <InstitutionModel>[
            makeInstitution(
              id: 'inst-1',
              name: 'Hope Hearing Center',
              institutionType: 'Support Center',
            ),
            makeInstitution(
              id: 'inst-2',
              name: 'Bright Vision Center',
              institutionType: 'Clinic',
            ),
          ];

          final disabilitiesByInstitution = <String, List<String>>{
            'inst-1': ['Hearing'],
            'inst-2': ['Visual'],
          };

          await tester.pumpWidget(
            buildInstitutionTestApp(
              child: _InstitutionIntegrationHarness(
                institutions: institutions,
                disabilitiesByInstitution: disabilitiesByInstitution,
              ),
            ),
          );

          await tester.pumpAndSettle();

          // This confirms both institutions are visible initially.
          expect(find.text('Hope Hearing Center'), findsOneWidget);
          expect(find.text('Bright Vision Center'), findsOneWidget);

          // This enters a query and filters the list.
          await tester.enterText(find.byType(TextField), 'hope');
          await tester.pumpAndSettle();

          expect(find.text('Hope Hearing Center'), findsOneWidget);
          expect(find.text('Bright Vision Center'), findsNothing);

          // This switches the disability filter to Hearing.
          await tester.tap(find.text('Hearing'));
          await tester.pumpAndSettle();

          expect(find.text('Hope Hearing Center'), findsOneWidget);
          expect(find.text('Bright Vision Center'), findsNothing);

          // This clears the search text from the search bar.
          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();

          expect(find.text('Hope Hearing Center'), findsOneWidget);

          // This switches the filter to Vision and shows the second institution.
          await tester.tap(find.text('Vision'));
          await tester.pumpAndSettle();

          expect(find.text('Bright Vision Center'), findsOneWidget);
          expect(find.text('Hope Hearing Center'), findsNothing);

          // This enters a query that causes an empty state.
          await tester.enterText(find.byType(TextField), 'unknown');
          await tester.pumpAndSettle();

          expect(find.textContaining('No institutions'), findsOneWidget);

          // This clears both the query and selected filter from the empty state.
          await tester.tap(find.text('Clear Filters'));
          await tester.pumpAndSettle();

          expect(find.text('Hope Hearing Center'), findsOneWidget);
          expect(find.text('Bright Vision Center'), findsOneWidget);
        });
  });
}
