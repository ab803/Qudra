import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_log_model.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_model.dart';
import 'package:qudra_0/Feature/medical_reminders/utils/date_time_helpers.dart';
import 'package:qudra_0/Feature/medical_reminders/utils/time_format_validator.dart';
import 'package:qudra_0/Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';

import 'Test_helpers.dart';

void main() {
  // This setup registers fallback values for mocktail once.
  setUpAll(() {
    registerMedicalRemindersFallbackValues();
  });

  group('Unit › ReminderModel', () {
    // This test verifies toMap serializes values correctly.
    test('toMap returns expected map', () {
      final reminder = makeReminder(
        id: 'r1',
        title: 'Vitamin C',
        subtitle: 'After breakfast',
        time: '08:30',
        isEnabled: true,
      );

      expect(
        reminder.toMap(),
        {
          'id': 'r1',
          'title': 'Vitamin C',
          'subtitle': 'After breakfast',
          'time': '08:30',
          'isEnabled': 1,
        },
      );
    });

    // This test verifies fromMap restores the same model values.
    test('fromMap creates reminder correctly', () {
      final reminder = ReminderModel.fromMap({
        'id': 'r2',
        'title': 'Omega 3',
        'subtitle': 'After lunch',
        'time': '14:00',
        'isEnabled': 0,
      });

      expect(reminder.id, 'r2');
      expect(reminder.title, 'Omega 3');
      expect(reminder.subtitle, 'After lunch');
      expect(reminder.time, '14:00');
      expect(reminder.isEnabled, false);
    });

    // This test verifies copyWith updates only provided fields.
    test('copyWith updates only changed fields', () {
      final reminder = makeReminder();
      final updated = reminder.copyWith(title: 'Updated', isEnabled: false);

      expect(updated.id, reminder.id);
      expect(updated.title, 'Updated');
      expect(updated.subtitle, reminder.subtitle);
      expect(updated.isEnabled, false);
    });
  });

  group('Unit › ReminderLogModel and ReminderDoseStatus', () {
    // This test verifies enum string mapping.
    test('ReminderDoseStatus value and fromValue work correctly', () {
      expect(ReminderDoseStatus.taken.value, 'taken');
      expect(ReminderDoseStatus.skipped.value, 'skipped');
      expect(ReminderDoseStatus.missed.value, 'missed');

      expect(
        ReminderDoseStatusX.fromValue('taken'),
        ReminderDoseStatus.taken,
      );
      expect(
        ReminderDoseStatusX.fromValue('skipped'),
        ReminderDoseStatus.skipped,
      );
      expect(
        ReminderDoseStatusX.fromValue('missed'),
        ReminderDoseStatus.missed,
      );
      expect(
        ReminderDoseStatusX.fromValue('unknown'),
        ReminderDoseStatus.missed,
      );
    });

    // This test verifies reminder log map conversion.
    test('ReminderLogModel toMap and fromMap work correctly', () {
      final log = makeLog(
        id: 'log-1',
        reminderId: 'r1',
        date: '2026-05-20',
        scheduledTime: '09:00',
        status: 'taken',
      );

      final map = log.toMap();
      final restored = ReminderLogModel.fromMap(map);

      expect(restored.id, 'log-1');
      expect(restored.reminderId, 'r1');
      expect(restored.date, '2026-05-20');
      expect(restored.scheduledTime, '09:00');
      expect(restored.status, 'taken');
    });
  });

  group('Unit › TimeFormatValidator', () {
    // This test verifies valid HH:mm strings.
    test('isValidHHmm accepts valid 24-hour values', () {
      expect(TimeFormatValidator.isValidHHmm('00:00'), true);
      expect(TimeFormatValidator.isValidHHmm('09:15'), true);
      expect(TimeFormatValidator.isValidHHmm('23:59'), true);
    });

    // This test verifies invalid HH:mm strings.
    test('isValidHHmm rejects invalid values', () {
      expect(TimeFormatValidator.isValidHHmm(null), false);
      expect(TimeFormatValidator.isValidHHmm(''), false);
      expect(TimeFormatValidator.isValidHHmm('24:00'), false);
      expect(TimeFormatValidator.isValidHHmm('12:60'), false);
      expect(TimeFormatValidator.isValidHHmm('abc'), false);
    });

    // This test verifies AM/PM normalization.
    test('normalizeToHHmm converts AM/PM correctly', () {
      expect(TimeFormatValidator.normalizeToHHmm('2:05 PM'), '14:05');
      expect(TimeFormatValidator.normalizeToHHmm('12:00 AM'), '00:00');
      expect(TimeFormatValidator.normalizeToHHmm('12:00 PM'), '12:00');
    });

    // This test verifies normal HH:mm normalization.
    test('normalizeToHHmm normalizes regular HH:mm correctly', () {
      expect(TimeFormatValidator.normalizeToHHmm('9:05'), '09:05');
      expect(TimeFormatValidator.normalizeToHHmm('23:10'), '23:10');
      expect(TimeFormatValidator.normalizeToHHmm('99:99'), null);
    });
  });

  group('Unit › DateTimeHelpers', () {
    // This test verifies today key format.
    test('todayKey returns yyyy-MM-dd format', () {
      final key = DateTimeHelpers.todayKey();
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key), true);
    });

    // This test verifies log id generation.
    test('generateLogId includes today key and reminder id', () {
      final logId = DateTimeHelpers.generateLogId('abc');
      expect(logId.contains('__abc'), true);
    });

    // This test verifies time parsing logic.
    test('scheduledDateTimeToday returns null for invalid values', () {
      expect(DateTimeHelpers.scheduledDateTimeToday(null), null);
      expect(DateTimeHelpers.scheduledDateTimeToday(''), null);
      expect(DateTimeHelpers.scheduledDateTimeToday('99:99'), null);
    });

    // This test verifies valid time parsing.
    test('scheduledDateTimeToday returns valid DateTime for HH:mm', () {
      final dt = DateTimeHelpers.scheduledDateTimeToday('08:45');
      expect(dt, isNotNull);
      expect(dt!.hour, 8);
      expect(dt.minute, 45);
    });
  });

  group('Unit › MedicalRemindersViewModel', () {
    late MockReminderService reminderService;
    late MockReminderLogService logService;
    late MockLocalNotificationService notificationService;
    late MedicalRemindersViewModel viewModel;

    setUp(() {
      reminderService = MockReminderService();
      logService = MockReminderLogService();
      notificationService = MockLocalNotificationService();

      viewModel = MedicalRemindersViewModel(
        reminderService,
        logService: logService,
        notificationService: notificationService,
      );
    });

    // This test verifies loadReminders loads reminders successfully.
    test('loadReminders loads reminders and clears loading state', () async {
      final reminders = [
        makeReminder(id: 'r1', time: futureTimeString()),
      ];

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => reminders);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);

      await viewModel.loadReminders();

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.reminders.length, 1);
      expect(viewModel.reminders.first.id, 'r1');
    });

    // This test verifies addReminder rejects invalid time.
    test('addReminder sets error when time is invalid', () async {
      final reminder = makeReminder(time: 'invalid');

      await viewModel.addReminder(reminder);

      expect(viewModel.errorMessage, 'valid_reminder_time');
      verifyNever(() => reminderService.createReminder(any()));
    });

    // This test verifies addReminder creates reminder and schedules notification.
    test('addReminder creates reminder and schedules notification', () async {
      final reminder = makeReminder(id: 'r10', time: futureTimeString());

      when(() => reminderService.createReminder(any()))
          .thenAnswer((_) async => 1);
      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);
      when(() => notificationService.scheduleReminder(any()))
          .thenAnswer((_) async {});

      await viewModel.addReminder(reminder);

      verify(() => reminderService.createReminder(any())).called(1);
      verify(() => notificationService.scheduleReminder(any())).called(1);
      expect(viewModel.reminders.length, 1);
      expect(viewModel.errorMessage, isNull);
    });

    // This test verifies deleteReminder removes reminder and cancels notification.
    test('deleteReminder removes item and cancels notification', () async {
      final reminder = makeReminder(id: 'r2', time: futureTimeString());

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);
      when(() => reminderService.deleteReminder('r2'))
          .thenAnswer((_) async => 1);
      when(() => logService.deleteLogsForReminder('r2'))
          .thenAnswer((_) async => 1);
      when(() => notificationService.cancelReminder('r2'))
          .thenAnswer((_) async {});

      await viewModel.loadReminders();
      await viewModel.deleteReminder('r2');

      expect(viewModel.reminders, isEmpty);
      verify(() => reminderService.deleteReminder('r2')).called(1);
      verify(() => logService.deleteLogsForReminder('r2')).called(1);
      verify(() => notificationService.cancelReminder('r2')).called(1);
    });

    // This test verifies toggleEnabled schedules notification when enabled.
    test('toggleEnabled(true) schedules reminder notification', () async {
      final reminder = makeReminder(
        id: 'r3',
        time: futureTimeString(),
        isEnabled: false,
      );

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);
      when(() => reminderService.setEnabled('r3', true))
          .thenAnswer((_) async => 1);
      when(() => notificationService.scheduleReminder(any()))
          .thenAnswer((_) async {});

      await viewModel.loadReminders();
      await viewModel.toggleEnabled('r3', true);

      expect(viewModel.reminders.first.isEnabled, true);
      verify(() => reminderService.setEnabled('r3', true)).called(1);
      verify(() => notificationService.scheduleReminder(any())).called(1);
    });

    // This test verifies toggleEnabled cancels notification when disabled.
    test('toggleEnabled(false) cancels reminder notification', () async {
      final reminder = makeReminder(
        id: 'r4',
        time: futureTimeString(),
        isEnabled: true,
      );

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => <ReminderLogModel>[]);
      when(() => reminderService.setEnabled('r4', false))
          .thenAnswer((_) async => 1);
      when(() => notificationService.cancelReminder('r4'))
          .thenAnswer((_) async {});

      await viewModel.loadReminders();
      await viewModel.toggleEnabled('r4', false);

      expect(viewModel.reminders.first.isEnabled, false);
      verify(() => reminderService.setEnabled('r4', false)).called(1);
      verify(() => notificationService.cancelReminder('r4')).called(1);
    });

    // This test verifies markTaken stores today's taken log.
    test('markTaken writes taken log and updates status label', () async {
      var currentLogs = <ReminderLogModel>[];
      final reminder = makeReminder(id: 'r5', time: futureTimeString());

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => currentLogs);
      when(() => logService.upsertLog(any())).thenAnswer((invocation) async {
        currentLogs = [invocation.positionalArguments.first as ReminderLogModel];
        return 1;
      });

      await viewModel.loadReminders();
      await viewModel.markTaken('r5');

      expect(viewModel.getStatusLabelForReminder('r5'), 'status_taken_today');
      verify(() => logService.upsertLog(any())).called(1);
    });

    // This test verifies skipDose stores today's skipped log.
    test('skipDose writes skipped log and updates status label', () async {
      var currentLogs = <ReminderLogModel>[];
      final reminder = makeReminder(id: 'r6', time: futureTimeString());

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => currentLogs);
      when(() => logService.upsertLog(any())).thenAnswer((invocation) async {
        currentLogs = [invocation.positionalArguments.first as ReminderLogModel];
        return 1;
      });

      await viewModel.loadReminders();
      await viewModel.skipDose('r6');

      expect(viewModel.getStatusLabelForReminder('r6'), 'status_skipped_today');
      verify(() => logService.upsertLog(any())).called(1);
    });

    // This test verifies a past-due reminder becomes missed automatically.
    test('past due reminder without log becomes missed', () async {
      var currentLogs = <ReminderLogModel>[];
      final reminder = makeReminder(id: 'r7', time: pastTimeString());

      when(() => reminderService.getAllReminders())
          .thenAnswer((_) async => [reminder]);
      when(() => logService.getLogsByDate(any()))
          .thenAnswer((_) async => currentLogs);
      when(() => logService.upsertLog(any())).thenAnswer((invocation) async {
        currentLogs = [invocation.positionalArguments.first as ReminderLogModel];
        return 1;
      });

      await viewModel.loadReminders();

      expect(viewModel.getStatusLabelForReminder('r7'), 'status_missed');
      expect(viewModel.missedTodayCount, 1);
      verify(() => logService.upsertLog(any())).called(1);
    });
  });
}