import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_empty_state.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_filter_bar.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_results_summary.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_search_bar.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_title_section.dart';
import 'package:qudra_0/Feature/institution/widgets/institution_top_header.dart';
import 'package:qudra_0/Feature/institution/widgets/service_tile.dart';

import '../institution_test/unit/Test_helpers.dart';

void main() {
  group('Widget › InstitutionTitleSection', () {
    // This test verifies the institutions page title appears.
    testWidgets('renders support centers title', (tester) async {
      await pumpInstitutionWidget(
        tester,
        child: const InstitutionTitleSection(),
      );

      await tester.pumpAndSettle();

      expect(find.text('Support Centers'), findsOneWidget);
    });
  });

  group('Widget › InstitutionTopHeader', () {
    // This test verifies the top header renders app name and icon.
    testWidgets('renders app title and account icon', (tester) async {
      await pumpInstitutionWidget(
        tester,
        child: const InstitutionTopHeader(),
      );

      await tester.pumpAndSettle();

      expect(find.text('Qudra'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });
  });

  group('Widget › InstitutionSearchBar', () {
    // This test verifies the search hint is displayed.
    testWidgets('renders search hint text', (tester) async {
      final controller = TextEditingController();

      await pumpInstitutionWidget(
        tester,
        child: InstitutionSearchBar(
          controller: controller,
          onClear: () {},
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search institutions...'), findsOneWidget);
    });

    // This test verifies clear button appears when controller has text.
    testWidgets('renders clear button when search text exists', (tester) async {
      final controller = TextEditingController(text: 'hope');

      await pumpInstitutionWidget(
        tester,
        child: InstitutionSearchBar(
          controller: controller,
          onClear: () {},
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('Widget › InstitutionFilterBar', () {
    // This test verifies chip callback is called when a filter is selected.
    testWidgets('calls onFilterSelected when chip is tapped', (tester) async {
      String? selected;

      await pumpInstitutionWidget(
        tester,
        child: InstitutionFilterBar(
          selectedFilter: 'All',
          onFilterSelected: (value) => selected = value,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobility'), findsOneWidget);
      await tester.tap(find.text('Mobility'));
      await tester.pumpAndSettle();

      expect(selected, 'Mobility');
    });
  });

  group('Widget › InstitutionResultsSummary', () {
    // This test verifies summary text for query and filter combination.
    testWidgets('renders summary for query and selected filter', (tester) async {
      await pumpInstitutionWidget(
        tester,
        child: const InstitutionResultsSummary(
          count: 2,
          query: 'hope',
          selectedFilter: 'Hearing',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Showing 2 results for "hope" in Hearing'),
          findsOneWidget);
    });
  });

  group('Widget › InstitutionEmptyState', () {
    // This test verifies empty state content and clear filters button.
    testWidgets('renders empty state with clear filters action',
            (tester) async {
          bool cleared = false;

          await pumpInstitutionWidget(
            tester,
            child: InstitutionEmptyState(
              query: 'not-found',
              selectedFilter: 'Hearing',
              onClearFilters: () => cleared = true,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.textContaining('No institutions match your search and filter'),
              findsOneWidget);
          expect(find.text('Clear Filters'), findsOneWidget);

          await tester.tap(find.text('Clear Filters'));
          await tester.pumpAndSettle();

          expect(cleared, true);
        });
  });

  group('Widget › ServiceTile', () {
    // This test verifies service tile content and booking action.
    testWidgets('renders service details and calls onBookNow',
            (tester) async {
          bool tapped = false;

          await pumpInstitutionWidget(
            tester,
            child: ServiceTile(
              service: makeInstitutionService(
                name: 'Speech Therapy',
                category: 'Therapy',
                workingDays: const ['Sunday', 'Monday'],
                workingStartTime: '09:00:00',
                workingEndTime: '17:00:00',
              ),
              onBookNow: () => tapped = true,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Speech Therapy'), findsOneWidget);
          expect(find.text('Therapy'), findsOneWidget);
          expect(find.text('Book Now'), findsOneWidget);

          await tester.tap(find.text('Book Now'));
          await tester.pumpAndSettle();

          expect(tapped, true);
        });
  });
}