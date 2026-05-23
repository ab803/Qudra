import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import 'package:qudra_0/Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_log_model.dart';

import 'unit/Test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // This setup registers fallback values once for integration tests.
  setUpAll(() {
    registerMedicalRemindersFallbackValues();
  });

  group('Integration › Medical Reminders', () {
    late MockReminderService reminderService;
    late MockReminderLogService logService;
    late MockLocalNotificationService notificationService;

    setUp(() {
      reminderService = MockReminderService();
      logService = MockReminderLogService();
      notificationService = MockLocalNotificationService();
    });

    // This test verifies the user can disable a reminder from the screen.
    testWidgets('user can toggle reminder state from the reminders screen',
            (tester) async {
          when(() => reminderService.getAllReminders()).thenAnswer(
                (_) async => [
              makeReminder(
                id: 'r1',
                title: 'Panadol',
                subtitle: 'After breakfast',
                time: futureTimeString(),
                isEnabled: true,
              ),
            ],
          );

          when(() => logService.getLogsByDate(any()))
              .thenAnswer((_) async => <ReminderLogModel>[]);

          when(() => reminderService.setEnabled('r1', false))
              .thenAnswer((_) async => 1);

          when(() => notificationService.cancelReminder('r1'))
              .thenAnswer((_) async {});

          final vm = MedicalRemindersViewModel(
            reminderService,
            logService: logService,
            notificationService: notificationService,
          );

          await vm.loadReminders();

          await tester.pumpWidget(
            buildMedicalRemindersTestApp(
              child: const MedicalRemindersView(),
              viewModel: vm,
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Panadol'), findsOneWidget);

          await tester.tap(find.byType(Switch));
          await tester.pumpAndSettle();

          verify(() => reminderService.setEnabled('r1', false)).called(1);
          verify(() => notificationService.cancelReminder('r1')).called(1);
        });
  });
}