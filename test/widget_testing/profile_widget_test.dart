import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_cubit.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/Feature/profile/presentation/views/app_guidelines_view.dart';
import 'package:qudra_0/Feature/profile/widgets/LanguageSwitchTile.dart';
import 'package:qudra_0/Feature/profile/widgets/disability_profile_card.dart';
import 'package:qudra_0/Feature/profile/widgets/labeled_readonly_field.dart';
import 'package:qudra_0/Feature/profile/widgets/profile_badge.dart';
import 'package:qudra_0/Feature/profile/widgets/profile_logout_button.dart';
import 'package:qudra_0/Feature/profile/widgets/profile_menu_item.dart';
import 'package:qudra_0/core/Services/Localization/language_cubit.dart';
import 'package:qudra_0/core/Services/Localization/language_state.dart';

import '../profile_test/unit/Test_helpers.dart';

void main() {
  // This setup registers fallback values once for mocktail.
  setUpAll(() {
    registerProfileFallbackValues();
  });

  group('Widget › ProfileBadge', () {
    // This test verifies the badge renders icon and text.
    testWidgets('renders badge text and icon', (tester) async {
      await pumpProfileWidget(
        tester,
        child: const ProfileBadge(
          icon: Icons.workspace_premium,
          text: 'Premium',
          bgColor: Colors.blue,
          textColor: Colors.white,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Premium'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });
  });

  group('Widget › ProfileMenuItem', () {
    // This test verifies tapping the menu item triggers the callback.
    testWidgets('calls ontap when tapped', (tester) async {
      bool tapped = false;

      await pumpProfileWidget(
        tester,
        child: ProfileMenuItem(
          icon: Icons.person,
          title: 'Personal Info',
          iconBg: Colors.orange,
          iconColor: Colors.white,
          ontap: () => tapped = true,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Personal Info'), findsOneWidget);

      await tester.tap(find.text('Personal Info'));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });

  group('Widget › LabeledReadonlyField', () {
    // This test verifies label, hint, and icons render correctly.
    testWidgets('renders label, hint, and icons', (tester) async {
      await pumpProfileWidget(
        tester,
        child: const LabeledReadonlyField(
          label: 'Email Address',
          hint: 'user@example.com',
          prefixIcon: Icons.mail_outline,
          trailingIcon: Icons.lock_outline,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });

  group('Widget › DisabilityProfileCard', () {
    // This test verifies disability profile card localized content appears.
    testWidgets('renders disability profile content', (tester) async {
      await pumpProfileWidget(
        tester,
        child: const DisabilityProfileCard(),
      );

      await tester.pumpAndSettle();

      expect(find.text('Disability Profile'), findsOneWidget);
      expect(find.text('Visual Impairment'), findsOneWidget);
    });
  });

  group('Widget › LanguageSwitchTile', () {
    late MockLanguageCubit mockLanguageCubit;

    setUp(() {
      mockLanguageCubit = MockLanguageCubit();

      // This mock provides the current state used by BlocBuilder.
      when(() => mockLanguageCubit.state)
          .thenReturn(const LanguageChanged(Locale('en')));

      // This mock provides an empty stream for BlocBuilder rebuild safety.
      when(() => mockLanguageCubit.stream)
          .thenAnswer((_) => const Stream<LanguageState>.empty());

      // This mock handles the language change call.
      when(() => mockLanguageCubit.changeLanguage(any()))
          .thenAnswer((_) async {});
    });

    // This test verifies changing language to Arabic triggers the cubit.
    testWidgets('calls changeLanguage when Arabic is selected', (tester) async {
      await tester.pumpWidget(
        BlocProvider<LanguageCubit>.value(
          value: mockLanguageCubit,
          child: buildProfileTestApp(
            child: const LanguageSwitchTile(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('Arabic'), findsOneWidget);

      await tester.tap(find.text('Arabic'));
      await tester.pumpAndSettle();

      verify(() => mockLanguageCubit.changeLanguage('ar')).called(1);
    });
  });

  group('Widget › ProfileLogoutButton', () {
    late MockAuthCubit mockAuthCubit;

    setUp(() {
      mockAuthCubit = MockAuthCubit();

      // This mock provides the current auth state used by BlocBuilder.
      when(() => mockAuthCubit.state).thenReturn(AuthInitial());

      // This mock provides an empty stream for BlocListener and BlocBuilder.
      when(() => mockAuthCubit.stream)
          .thenAnswer((_) => const Stream<AuthState>.empty());

      // This mock handles logout call.
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});
    });

    // This test verifies tapping logout calls the cubit logout method.
    testWidgets('calls logout when button is tapped', (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: buildProfileTestApp(
            child: const ProfileLogoutButton(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Log Out'), findsOneWidget);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthCubit.logout()).called(1);
    });
  });

  group('Widget › AppGuidelinesView', () {
    // This test verifies the guidelines screen renders the main content.
    testWidgets('renders intro and major sections', (tester) async {
      final router = GoRouter(
        initialLocation: '/guidelines',
        routes: [
          GoRoute(
            path: '/guidelines',
            builder: (context, state) => const AppGuidelinesView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:profile')),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:chat')),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:reminders')),
          ),
          GoRoute(
            path: '/accessibility',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:accessibility')),
          ),
          GoRoute(
            path: '/emergency-entry',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:emergency')),
          ),
          GoRoute(
            path: '/institution',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:institution')),
          ),
          GoRoute(
            path: '/feedback',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:feedback')),
          ),
        ],
      );

      await tester.pumpWidget(
        buildProfileRouterApp(router: router),
      );

      await tester.pumpAndSettle();

      expect(find.text('How can we help?'), findsOneWidget);
      expect(find.text('Still need help?'), findsOneWidget);
      expect(find.text('Contact Support'), findsOneWidget);
    });

    // This test verifies searching and topic filtering update the visible guidelines.
    testWidgets('filters guideline cards by search and topic', (tester) async {
      final router = GoRouter(
        initialLocation: '/guidelines',
        routes: [
          GoRoute(
            path: '/guidelines',
            builder: (context, state) => const AppGuidelinesView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:profile')),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:chat')),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:reminders')),
          ),
          GoRoute(
            path: '/accessibility',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:accessibility')),
          ),
          GoRoute(
            path: '/emergency-entry',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:emergency')),
          ),
          GoRoute(
            path: '/institution',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:institution')),
          ),
          GoRoute(
            path: '/feedback',
            builder: (context, state) =>
            const Scaffold(body: Text('stub:feedback')),
          ),
        ],
      );

      await tester.pumpWidget(
        buildProfileRouterApp(router: router),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'reminders');
      await tester.pumpAndSettle();

      expect(find.text('Setting Medical Reminders'), findsOneWidget);

      // This taps the first visible Health chip to avoid ambiguous text matches.
      await tester.tap(find.text('Health').first);
      await tester.pumpAndSettle();

      expect(find.text('Setting Medical Reminders'), findsOneWidget);
    });
  });
}
