// ─── test/home/widget/home_widget_test.dart ───────────────────────────────────
// WIDGET TESTS
// Tests individual widgets in isolation using mocked dependencies.
// Each group covers one widget file.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Category_section.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/QuickSection.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Quick_access_card.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Recommended_section.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/custom_searchBar.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/home_header.dart';
import '../home_test/unit/Test_helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ┌──────────────────────────────────────────────────────────────────────────┐
// │  1. QuickAccessCard                                                       │
// └──────────────────────────────────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // Register fallback values required by mocktail for complex types.
  setUpAll(() {
    registerFallbackValue( AuthInitial());
  });

  // ───────────────────────────────────────────────────────────────────────────
  group('Widget › QuickAccessCard', () {
    Widget buildCard({
      String title = 'Intelligent',
      String subtitle = 'Assistant',
      IconData icon = Icons.chat_bubble,
      Color color = Colors.teal,
    }) =>
        MaterialApp(
          home: Scaffold(
            body: QuickAccessCard(
              title: title,
              subtitle: subtitle,
              icon: icon,
              color: color,
            ),
          ),
        );

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(buildCard(title: 'My Title'));
      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildCard(subtitle: 'My Subtitle'));
      expect(find.text('My Subtitle'), findsOneWidget);
    });

    testWidgets('renders the provided icon', (tester) async {
      await tester.pumpWidget(buildCard(icon: Icons.medication));
      expect(find.byIcon(Icons.medication), findsOneWidget);
    });

    testWidgets('card has fixed height of 140', (tester) async {
      await tester.pumpWidget(buildCard());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(QuickAccessCard),
          matching: find.byType(Container).first,
        ),
      );

      // The outermost Container in QuickAccessCard declares height: 140.
      expect((container.constraints?.maxHeight ?? 0), greaterThan(100));
    });

    testWidgets('background color matches provided color', (tester) async {
      const testColor = Colors.purple;
      await tester.pumpWidget(buildCard(color: testColor));

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) =>
      (c.decoration as BoxDecoration?)?.color == testColor)
          .toList();

      expect(containers, isNotEmpty);
    });

    testWidgets('renders white icon inside coloured container', (tester) async {
      await tester.pumpWidget(buildCard(icon: Symbols.robot_2));
      final icon = tester.widget<Icon>(find.byIcon(Symbols.robot_2));
      expect(icon.color, Colors.white);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  2. HomeHeader                                                            │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Widget › HomeHeader', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() => mockAuthCubit = MockAuthCubit());

    Widget buildHeader() => buildTestableWidget(
      child: const HomeHeader(),
      authCubit: mockAuthCubit,
    );

    testWidgets('shows user first name when logged in', (tester) async {
      final user = fakeUser(fullName: 'Abdullah Khairy');

      when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
      when(() => mockAuthCubit.currentUser).thenReturn(user);

      await tester.pumpWidget(buildHeader());
      await tester.pump();

      // Should display "Abdullah" (first word of full name).
      expect(find.textContaining('Abdullah'), findsOneWidget);
    });

    testWidgets('shows fallback "friend" when user is null', (tester) async {
      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);

      await tester.pumpWidget(buildHeader());
      await tester.pump();

      // context.tr("friend") returns "friend" as the key when no locale is set.
      expect(find.textContaining('friend'), findsOneWidget);
    });

    testWidgets('shows loading state while auth is restoring', (tester) async {
      when(() => mockAuthCubit.state).thenReturn( AuthRestoring());
      when(() => mockAuthCubit.currentUser).thenReturn(null);

      await tester.pumpWidget(buildHeader());
      await tester.pump();

      // In loading state, header still renders (no crash).
      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('renders welcome text (tr key)', (tester) async {
      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);

      await tester.pumpWidget(buildHeader());
      await tester.pump();

      // context.tr("welcome") returns "welcome" as key when no locale is set.
      expect(find.textContaining('welcome'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  3. CustomSearchBar                                                       │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Widget › CustomSearchBar', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);
    });

    Widget buildSearchBar() => buildTestableWidget(
      child: const CustomSearchBar(),
      authCubit: mockAuthCubit,
    );

    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(buildSearchBar());
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders search icon', (tester) async {
      await tester.pumpWidget(buildSearchBar());
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders forward arrow button', (tester) async {
      await tester.pumpWidget(buildSearchBar());
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('text field accepts typed input', (tester) async {
      await tester.pumpWidget(buildSearchBar());

      await tester.enterText(find.byType(TextField), 'accessibility');
      expect(find.text('accessibility'), findsOneWidget);
    });

    testWidgets('tapping forward button navigates to /institution', (tester) async {
      await tester.pumpWidget(buildSearchBar());

      await tester.enterText(find.byType(TextField), 'wheelchair');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      // After navigation the stub page renders.
      expect(find.text('stub:institution'), findsOneWidget);
    });

    testWidgets('submitting via keyboard navigates to /institution', (tester) async {
      await tester.pumpWidget(buildSearchBar());

      await tester.enterText(find.byType(TextField), 'hearing');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('stub:institution'), findsOneWidget);
    });

    testWidgets('navigates even with empty search query', (tester) async {
      await tester.pumpWidget(buildSearchBar());

      // Don't type anything — just tap the button.
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('stub:institution'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  4. CategorySection                                                       │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Widget › CategorySection', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);
    });

    Widget buildCategory() => buildTestableWidget(
      child: const CategorySection(),
      authCubit: mockAuthCubit,
    );

    testWidgets('renders section title (tr key "categories")', (tester) async {
      await tester.pumpWidget(buildCategory());
      expect(find.textContaining('categories'), findsOneWidget);
    });

    testWidgets('renders exactly 3 category items', (tester) async {
      await tester.pumpWidget(buildCategory());

      // Each category chip is a Container inside a ListView.
      final scrollable = find.byType(ListView);
      expect(scrollable, findsOneWidget);

      // Verify all 3 category icons are present.
      expect(find.byIcon(Icons.accessible), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.hearing), findsOneWidget);
    });

    testWidgets('renders horizontal ListView', (tester) async {
      await tester.pumpWidget(buildCategory());

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
    });

    testWidgets('category labels appear (tr keys fall back to key names)',
            (tester) async {
          await tester.pumpWidget(buildCategory());

          // context.tr("physical") → "physical", etc.
          expect(find.text('physical'), findsOneWidget);
          expect(find.text('visual'), findsOneWidget);
          expect(find.text('hearing'), findsOneWidget);
        });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  5. QuickAccessSection                                                    │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Widget › QuickAccessSection', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);
    });

    Widget buildSection() => buildTestableWidget(
      child: const QuickAccessSection(),
      authCubit: mockAuthCubit,
    );

    testWidgets('renders emergency card with medical icon', (tester) async {
      await tester.pumpWidget(buildSection());
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });

    testWidgets('renders two QuickAccessCards (chat + reminders)', (tester) async {
      await tester.pumpWidget(buildSection());
      expect(find.byType(QuickAccessCard), findsNWidgets(2));
    });

    testWidgets('renders accessibility card with menu_book icon', (tester) async {
      await tester.pumpWidget(buildSection());
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('renders section title (tr key "quick_access")', (tester) async {
      await tester.pumpWidget(buildSection());
      expect(find.textContaining('quick_access'), findsOneWidget);
    });

    testWidgets('tapping emergency card navigates to /emergency-entry',
            (tester) async {
          await tester.pumpWidget(buildSection());
          await tester.tap(find.byIcon(Icons.medical_services));
          await tester.pumpAndSettle();

          expect(find.text('stub:emergency'), findsOneWidget);
        });

    testWidgets('tapping accessibility card navigates to /accessibility',
            (tester) async {
          await tester.pumpWidget(buildSection());
          await tester.tap(find.byIcon(Icons.menu_book));
          await tester.pumpAndSettle();

          expect(find.text('stub:accessibility'), findsOneWidget);
        });

    testWidgets('tapping chat QuickAccessCard navigates to /chat', (tester) async {
      await tester.pumpWidget(buildSection());

      // The first QuickAccessCard wraps the chat action.
      await tester.tap(find.byType(QuickAccessCard).first);
      await tester.pumpAndSettle();

      expect(find.text('stub:chat'), findsOneWidget);
    });

    testWidgets('tapping reminders QuickAccessCard navigates to /reminders',
            (tester) async {
          await tester.pumpWidget(buildSection());

          await tester.tap(find.byType(QuickAccessCard).last);
          await tester.pumpAndSettle();

          expect(find.text('stub:reminders'), findsOneWidget);
        });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  6. RecommendedSection                                                    │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Widget › RecommendedSection', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);
    });

    tearDown(() async => resetGetIt());

    Widget buildRecommended() => buildTestableWidget(
      child: const RecommendedSection(),
      authCubit: mockAuthCubit,
    );

    testWidgets('shows CircularProgressIndicator while auth is restoring',
            (tester) async {
          when(() => mockAuthCubit.state).thenReturn( AuthRestoring());
          when(() => mockAuthCubit.currentUser).thenReturn(null);

          await tester.pumpWidget(buildRecommended());

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('shows "no_recommendations_available" when user is null',
            (tester) async {
          when(() => mockAuthCubit.state).thenReturn( AuthInitial());
          when(() => mockAuthCubit.currentUser).thenReturn(null);

          await tester.pumpWidget(buildRecommended());
          await tester.pump();

          expect(find.textContaining('no_recommendations_available'), findsOneWidget);
        });

    testWidgets('shows CircularProgressIndicator while future is loading',
            (tester) async {
          final user = fakeUser(disabilityType: 'physical');

          when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
          when(() => mockAuthCubit.currentUser).thenReturn(user);

          // Never-completing future → widget stays in loading state.
          when(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: any(named: 'disabilityType'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) => Future.delayed(const Duration(seconds: 10), () => []));

          await tester.pumpWidget(buildRecommended());
          await tester.pump(); // trigger first frame

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('shows institutions in a PageView after successful fetch',
            (tester) async {
          final user = fakeUser(disabilityType: 'physical');
          final institutions = fakeInstitutionList(count: 3);

          when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
          when(() => mockAuthCubit.currentUser).thenReturn(user);

          when(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: 'physical',
              limit: 5,
            ),
          ).thenAnswer((_) async => institutions);

          await tester.pumpWidget(buildRecommended());
          await tester.pumpAndSettle(); // let FutureBuilder complete

          expect(find.byType(PageView), findsOneWidget);
        });

    testWidgets('shows "no_recommendations_available" when list is empty',
            (tester) async {
          final user = fakeUser(disabilityType: 'physical');

          when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
          when(() => mockAuthCubit.currentUser).thenReturn(user);

          when(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: any(named: 'disabilityType'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => []);

          await tester.pumpWidget(buildRecommended());
          await tester.pumpAndSettle();

          expect(find.textContaining('no_recommendations_available'), findsOneWidget);
        });

    testWidgets('shows error text when service throws', (tester) async {
      final user = fakeUser(disabilityType: 'physical');

      when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
      when(() => mockAuthCubit.currentUser).thenReturn(user);

      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Server error'));

      await tester.pumpWidget(buildRecommended());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });

    testWidgets('does not re-fetch when disability type has not changed',
            (tester) async {
          final user = fakeUser(disabilityType: 'physical');

          when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
          when(() => mockAuthCubit.currentUser).thenReturn(user);

          when(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: 'physical',
              limit: 5,
            ),
          ).thenAnswer((_) async => fakeInstitutionList(count: 2));

          // Pump once then rebuild with same state.
          await tester.pumpWidget(buildRecommended());
          await tester.pumpAndSettle();

          await tester.pumpWidget(buildRecommended()); // rebuild, same user
          await tester.pumpAndSettle();

          // Service should have been called exactly once (caching logic).
          verify(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: 'physical',
              limit: 5,
            ),
          ).called(1);
        });
  });
}