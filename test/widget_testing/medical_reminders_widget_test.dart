import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_log_model.dart';
import 'package:qudra_0/Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import 'package:qudra_0/Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';
import 'package:qudra_0/Feature/medical_reminders/widgets/meds_header.dart';
import 'package:qudra_0/Feature/medical_reminders/widgets/meds_progress_card.dart';
import 'package:qudra_0/Feature/medical_reminders/widgets/meds_reminder_tile.dart';

import '../medical_reminders_test/unit/Test_helpers.dart';

void main() {
  // This setup registers fallback values for mocktail once.
  setUpAll(() {
    registerMedicalRemindersFallbackValues();
  });

  group('Widget › MedsHeader', () {
    // This test verifies the localized header title appears.
    testWidgets('renders medical reminders title', (tester) async {
      await pumpMedicalRemindersWidget(
        tester,
        child: const MedsHeader(),
      );

      // This extra pump gives localization time to settle.
      await tester.pumpAndSettle();

      expect(find.text('Medical Reminders'), findsOneWidget);
    });
  });

  group('Widget › MedsProgressCard', () {
    // This test verifies progress card content appears correctly.
    testWidgets('renders progress numbers and footer', (tester) async {
      await pumpMedicalRemindersWidget(
        tester,
        child: const MedsProgressCard(
          taken: 2,
          total: 3,
          caption: 'Doses completed',
          footerText: 'Next at 10:00 AM',
          missedCount: 0,
        ),
      );

      // This extra pump ensures the widget tree is stable before asserting.
      await tester.pumpAndSettle();

      expect(find.text('2/3'), findsOneWidget);
      expect(find.text('Doses completed'), findsOneWidget);
      expect(find.text('Next at 10:00 AM'), findsOneWidget);
    });
  });

  group('Widget › MedsReminderTile', () {
    // This test verifies the tile renders the reminder data.
    testWidgets('renders title subtitle and time', (tester) async {
      final tile = MedsReminderTile(
        data: ReminderViewData(
          id: 'r1',
          title: 'Panadol',
          subtitle: 'After breakfast',
          timeText: '9:00 AM',
          isEnabled: true,
          statusLabel: 'status_taken_today',
        ),
      );

      await pumpMedicalRemindersWidget(
        tester,
        child: tile,
      );

      // This extra pump gives localization time to resolve the status label.
      await tester.pumpAndSettle();

      expect(find.text('Panadol'), findsOneWidget);
      expect(find.text('After breakfast'), findsOneWidget);
      expect(find.text('9:00 AM'), findsOneWidget);
      expect(find.text('Taken today'), findsOneWidget);
    });

    // This test verifies the adaptive switch triggers the callback.
    testWidgets('calls onToggle when switch changes', (tester) async {
      bool? latestValue;

      final tile = MedsReminderTile(
        data: ReminderViewData(
          id: 'r2',
          title: 'Vitamin C',
          subtitle: 'After lunch',
          timeText: '1:00 PM',
          isEnabled: true,
        ),
        onToggle: (value) => latestValue = value,
      );

      await pumpMedicalRemindersWidget(
        tester,
        child: tile,
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(latestValue, false);
    });

    // This test verifies the tile long press callback is called.
    testWidgets('calls onLongPress when tile is long pressed', (tester) async {
      bool longPressed = false;

      final tile = MedsReminderTile(
        data: ReminderViewData(
          id: 'r3',
          title: 'Omega 3',
          subtitle: 'Daily',
          timeText: '8:00 PM',
          isEnabled: true,
        ),
        onLongPress: () => longPressed = true,
      );

      await pumpMedicalRemindersWidget(
        tester,
        child: tile,
      );

      await tester.pumpAndSettle();

      expect(find.text('Omega 3'), findsOneWidget);

      await tester.longPress(find.text('Omega 3'));
      await tester.pumpAndSettle();

      expect(longPressed, true);
    });
  });

  group('Widget › MedicalRemindersView', () {
    late MockReminderService reminderService;
    late MockReminderLogService logService;
    late MockLocalNotificationService notificationService;

    setUp(() {
      reminderService = MockReminderService();
      logService = MockReminderLogService();
      notificationService = MockLocalNotificationService();
    });

    // This test verifies the empty state appears when there are no reminders.
    testWidgets('shows empty state when reminders list is empty',
            (tester) async {
          when(() => reminderService.getAllReminders())
              .thenAnswer((_) async => []);
          when(() => logService.getLogsByDate(any()))
              .thenAnswer((_) async => <ReminderLogModel>[]);

          final vm = MedicalRemindersViewModel(
            reminderService,
            logService: logService,
            notificationService: notificationService,
          );

          await vm.loadReminders();

          await pumpMedicalRemindersWidget(
            tester,
            child: const MedicalRemindersView(),
            viewModel: vm,
          );

          // This settle is safe because no swipe-hint tile exists in empty state.
          await tester.pumpAndSettle();

          expect(find.text('No reminders yet. Tap + to add one.'), findsOneWidget);
        });

    // This test verifies reminder tiles appear when reminders exist.
    testWidgets('shows reminder tiles when reminders exist', (tester) async {
      when(() => reminderService.getAllReminders()).thenAnswer(
            (_) async => [
          makeReminder(
            id: 'r1',
            title: 'Panadol',
            subtitle: 'After breakfast',
            time: futureTimeString(),
          ),
        ],
      );

      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);

      final vm = MedicalRemindersViewModel(
        reminderService,
        logService: logService,
        notificationService: notificationService,
      );

      await vm.loadReminders();

      await pumpMedicalRemindersWidget(
        tester,
        child: const MedicalRemindersView(),
        viewModel: vm,
      );

      // This first pump builds the screen.
      await tester.pump();

      // This short pump lets the first frames render without waiting forever.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Panadol'), findsOneWidget);
      expect(find.text('After breakfast'), findsOneWidget);
      expect(find.byType(MedsReminderTile), findsOneWidget);

      // This long pump finishes the swipe hint timers and animation safely.
      await tester.pump(const Duration(seconds: 5));

      // This disposes the animated widget tree cleanly before test end.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
