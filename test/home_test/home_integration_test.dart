import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/Feature/Home/presentation/views/home_view.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Category_section.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/QuickSection.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Quick_access_card.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/Recommended_section.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/custom_searchBar.dart';
import 'package:qudra_0/Feature/Home/presentation/widgets/home_header.dart';
import 'unit/Test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbackValue( AuthInitial());
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  1. Structure — all sections are present                                  │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Integration › HomeView — structure', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);

      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);

      // Default: return empty list so tests don't hang on network.
      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    });

    tearDown(() async => resetGetIt());

    testWidgets('HomeView renders without errors', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
    });

    testWidgets('HomeHeader is present', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('CustomSearchBar is present', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomSearchBar), findsOneWidget);
    });

    testWidgets('CategorySection is present', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategorySection), findsOneWidget);
    });

    testWidgets('RecommendedSection is present', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecommendedSection), findsOneWidget);
    });

    testWidgets('QuickAccessSection is present', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QuickAccessSection), findsOneWidget);
    });

    testWidgets('body is scrollable (SingleChildScrollView)', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  2. Auth state → HomeHeader integration                                   │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Integration › HomeView — auth state propagation', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);

      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    });

    tearDown(() async => resetGetIt());

    testWidgets('HomeHeader shows user first name when logged in', (tester) async {
      final user = fakeUser(fullName: 'Yasmine Hassan');

      when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
      when(() => mockAuthCubit.currentUser).thenReturn(user);

      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Yasmine'), findsOneWidget);
    });

    testWidgets('HomeHeader falls back to "friend" when no user', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);

      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('friend'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  3. Navigation flows                                                      │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Integration › HomeView — navigation', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);

      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);
      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    });

    tearDown(() async => resetGetIt());

    testWidgets('search submit navigates to /institution', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ramp access');
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('stub:institution'), findsOneWidget);
    });

    testWidgets('tapping emergency card navigates to /emergency-entry',
            (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.medical_services));
          await tester.pumpAndSettle();

          expect(find.text('stub:emergency'), findsOneWidget);
        });

    testWidgets('tapping accessibility card navigates to /accessibility',
            (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
          );
          await tester.pumpAndSettle();

          // Scroll down to make the accessibility card visible.
          await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.menu_book));
          await tester.pumpAndSettle();

          expect(find.text('stub:accessibility'), findsOneWidget);
        });

    testWidgets('tapping chat card navigates to /chat', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(child: const HomeView(), authCubit: mockAuthCubit),
      );
      await tester.pumpAndSettle();

      // Scroll down to the QuickAccessSection.
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // First QuickAccessCard = chat.
      await tester.tap(find.byType(QuickAccessSection));
      // More specific tap using the first GestureDetector wrapping a QuickAccessCard:
      final chatCard = find.byType(QuickAccessCard).first;
      await tester.tap(chatCard);
      await tester.pumpAndSettle();

      expect(find.text('stub:chat'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  4. RecommendedSection integration with auth + service                   │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Integration › HomeView — recommendations integration', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);
    });

    tearDown(() async => resetGetIt());

    testWidgets(
      'institutions are displayed in PageView when user is logged in and service returns data',
          (tester) async {
        final user = fakeUser(disabilityType: 'visual');
        final institutions = fakeInstitutionList(count: 2);

        when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
        when(() => mockAuthCubit.currentUser).thenReturn(user);

        when(
              () => mockService.fetchRecommendedInstitutions(
            disabilityType: 'visual',
            limit: 5,
          ),
        ).thenAnswer((_) async => institutions);

        await tester.pumpWidget(
          buildTestableWidget(
              child: const HomeView(), authCubit: mockAuthCubit),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PageView), findsOneWidget);
      },
    );

    testWidgets(
      'service is called with the correct disability type from the authenticated user',
          (tester) async {
        final user = fakeUser(disabilityType: 'hearing');

        when(() => mockAuthCubit.state).thenReturn(LoginSuccess(user: user));
        when(() => mockAuthCubit.currentUser).thenReturn(user);

        when(
              () => mockService.fetchRecommendedInstitutions(
            disabilityType: 'hearing',
            limit: 5,
          ),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          buildTestableWidget(
              child: const HomeView(), authCubit: mockAuthCubit),
        );
        await tester.pumpAndSettle();

        verify(
              () => mockService.fetchRecommendedInstitutions(
            disabilityType: 'hearing',
            limit: 5,
          ),
        ).called(1);
      },
    );

    testWidgets('no service call is made when user is not logged in',
            (tester) async {
          when(() => mockAuthCubit.state).thenReturn( AuthInitial());
          when(() => mockAuthCubit.currentUser).thenReturn(null);

          await tester.pumpWidget(
            buildTestableWidget(
                child: const HomeView(), authCubit: mockAuthCubit),
          );
          await tester.pumpAndSettle();

          verifyNever(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: any(named: 'disabilityType'),
              limit: any(named: 'limit'),
            ),
          );
        });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ┌──────────────────────────────────────────────────────────────────────────┐
  // │  5. Theme integration — dark mode                                         │
  // └──────────────────────────────────────────────────────────────────────────┘
  // ───────────────────────────────────────────────────────────────────────────

  group('Integration › HomeView — theme', () {
    late MockAuthCubit mockAuthCubit;
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockAuthCubit = MockAuthCubit();
      mockService = MockInstitutionFeatureService();
      registerMockInstitutionService(mockService);

      when(() => mockAuthCubit.state).thenReturn( AuthInitial());
      when(() => mockAuthCubit.currentUser).thenReturn(null);
      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);
    });

    tearDown(() async => resetGetIt());

    testWidgets('renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const HomeView(),
          authCubit: mockAuthCubit,
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders correctly in light theme', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const HomeView(),
          authCubit: mockAuthCubit,
          theme: ThemeData.light(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}