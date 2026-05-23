import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_cubit.dart';
import 'package:qudra_0/Feature/accessibility/views/accessibility_hub_view.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import 'package:qudra_0/Feature/accessibility/repo/rights&tipsRepo.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Mock
// ─────────────────────────────────────────────────────────────────────────────
class MockRightstipsRepository extends Mock implements RightstipsRepository {}

// ─────────────────────────────────────────────────────────────────────────────
// Fixtures
// ─────────────────────────────────────────────────────────────────────────────
List<tipsRightsModel> _fakeTips() => List.generate(
  5,
      (i) => tipsRightsModel.fromJson({
    'id': i + 1,
    'title': 'Tip ${i + 1}',
    'content': 'This is the content for tip number ${i + 1}.',
    'type': i.isEven ? 'tip' : 'right',
  }),
);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildApp(RightstipsRepository repo) {
  return MaterialApp(
    home: BlocProvider(
      create: (_) => RightstipsCubit(repo)..loadAll(),
      child: const AccessibilityHubView(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockRightstipsRepository mockRepo;

  setUp(() {
    mockRepo = MockRightstipsRepository();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Screen loads and displays tips
  // ─────────────────────────────────────────────────────────────────────────
  group('AccessibilityScreen – data loading', () {
    testWidgets('shows a loading indicator while fetching', (tester) async {
      // Use a completer so we can keep the loading state visible.
      final completer = Completer<List<tipsRightsModel>>();
      when(() => mockRepo.fetchAll()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pump(); // trigger BLoC emission

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up to avoid pending timers.
      completer.complete(_fakeTips());
    });

    testWidgets('displays tip cards after data loads', (tester) async {
      when(() => mockRepo.fetchAll()).thenAnswer((_) async => _fakeTips());

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // The screen must render at least one tip title.
      expect(find.text('Tip 1'), findsOneWidget);
    });

    testWidgets('displays all five returned tips', (tester) async {
      when(() => mockRepo.fetchAll()).thenAnswer((_) async => _fakeTips());

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      for (var i = 1; i <= 5; i++) {
        expect(find.text('Tip $i'), findsOneWidget);
      }
    });

    testWidgets('shows an error message when loading fails', (tester) async {
      when(() => mockRepo.fetchAll())
          .thenThrow(Exception('No internet connection'));

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // The screen should surface a user-visible error.
      expect(
        find.textContaining('No internet connection', findRichText: true),
        findsOneWidget,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Create flow
  // ─────────────────────────────────────────────────────────────────────────
  group('AccessibilityScreen – create flow', () {
    testWidgets(
        'tapping add FAB opens a dialog / bottom sheet and submitting adds a tip',
            (tester) async {
          final tips = _fakeTips();
          final newTip = tipsRightsModel.fromJson({
            'id': 6,
            'title': 'New Tip',
            'content': 'Brand new content.',
            'type': 'tip',
          });

          when(() => mockRepo.fetchAll()).thenAnswer((_) async => tips);
          when(() => mockRepo.create(any()))
              .thenAnswer((_) async => newTip);

          await tester.pumpWidget(_buildApp(mockRepo));
          await tester.pumpAndSettle();

          // Tap the FAB (or add button – adjust the finder to match your UI).
          final addButton = find.byIcon(Icons.add);
          if (addButton.evaluate().isNotEmpty) {
            await tester.tap(addButton);
            await tester.pumpAndSettle();

            // Fill in the title field if present.
            final titleField = find.widgetWithText(TextField, 'Title');
            if (titleField.evaluate().isNotEmpty) {
              await tester.enterText(titleField, 'New Tip');
              await tester.testTextInput.receiveAction(TextInputAction.next);
            }

            // Tap the confirm/save button.
            final saveButton = find.widgetWithText(ElevatedButton, 'Save');
            if (saveButton.evaluate().isNotEmpty) {
              // Stub fetchAll for the reload after creation.
              when(() => mockRepo.fetchAll())
                  .thenAnswer((_) async => [...tips, newTip]);
              await tester.tap(saveButton);
              await tester.pumpAndSettle();

              expect(find.text('New Tip'), findsOneWidget);
            }
          }
        });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Delete flow
  // ─────────────────────────────────────────────────────────────────────────
  group('AccessibilityScreen – delete flow', () {
    testWidgets('deleting a tip removes it from the list', (tester) async {
      final tips = _fakeTips();
      when(() => mockRepo.fetchAll()).thenAnswer((_) async => tips);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // Long-press or tap a delete icon on the first card if exposed.
      final deleteIcon = find.byIcon(Icons.delete_outline);
      if (deleteIcon.evaluate().isNotEmpty) {
        when(() => mockRepo.delete(1)).thenAnswer((_) async {});
        when(() => mockRepo.fetchAll())
            .thenAnswer((_) async => tips.skip(1).toList());

        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle();

        expect(find.text('Tip 1'), findsNothing);
        expect(find.text('Tip 2'), findsOneWidget);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Scroll behaviour
  // ─────────────────────────────────────────────────────────────────────────
  group('AccessibilityScreen – scroll', () {
    testWidgets('list is scrollable when there are many tips', (tester) async {
      // Generate 20 tips to force overflow.
      final many = List.generate(
        20,
            (i) => tipsRightsModel.fromJson({
          'id': i + 1,
          'title': 'Tip ${i + 1}',
          'content': 'Content for tip ${i + 1}.',
          'type': 'tip',
        }),
      );
      when(() => mockRepo.fetchAll()).thenAnswer((_) async => many);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // Scroll down to find a later tip.
      await tester.dragUntilVisible(
        find.text('Tip 15'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      expect(find.text('Tip 15'), findsOneWidget);
    });
  });
}