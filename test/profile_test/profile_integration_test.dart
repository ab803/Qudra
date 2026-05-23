import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qudra_0/Feature/profile/presentation/views/app_guidelines_view.dart';

import 'unit/Test_helpers.dart';

void main() {
  // This binding enables integration test execution.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration › Profile', () {
    // This test verifies the user can search guidelines, filter by topic,
    // and navigate to the reminders route from the guidelines screen.
    testWidgets('user can search guidelines and open reminders route',
            (tester) async {
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

          // This enters a query that should match the reminders guideline.
          await tester.enterText(find.byType(TextField), 'reminders');
          await tester.pumpAndSettle();

          expect(find.text('Setting Medical Reminders'), findsOneWidget);

          // This taps the first visible Health topic chip to avoid ambiguous text matches.
          await tester.tap(find.text('Health').first);
          await tester.pumpAndSettle();

          expect(find.text('Setting Medical Reminders'), findsOneWidget);

          // This scrolls until the reminders action button becomes visible.
          final openRemindersFinder = find.text('Open Reminders');
          await tester.scrollUntilVisible(
            openRemindersFinder,
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();

          // This taps the guideline action button after ensuring it is visible.
          await tester.tap(openRemindersFinder);
          await tester.pumpAndSettle();

          expect(find.text('stub:reminders'), findsOneWidget);
        });
  });
}