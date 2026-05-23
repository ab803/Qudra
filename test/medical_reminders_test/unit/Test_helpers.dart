import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_log_model.dart';
import 'package:qudra_0/Feature/medical_reminders/models/reminder_model.dart';
import 'package:qudra_0/Feature/medical_reminders/services/local_notification_service.dart';
import 'package:qudra_0/Feature/medical_reminders/services/reminder_log_service.dart';
import 'package:qudra_0/Feature/medical_reminders/services/reminder_service.dart';
import 'package:qudra_0/Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';

// This mock simulates reminder service behavior in tests.
class MockReminderService extends Mock implements ReminderService {}

// This mock simulates reminder log service behavior in tests.
class MockReminderLogService extends Mock implements ReminderLogService {}

// This mock simulates local notifications behavior in tests.
class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

// This helper registers fallback models used by mocktail.
void registerMedicalRemindersFallbackValues() {
  registerFallbackValue(
    const ReminderModel(
      id: 'fallback-id',
      title: 'fallback-title',
      subtitle: 'fallback-subtitle',
      time: '09:00',
      isEnabled: true,
    ),
  );

  registerFallbackValue(
    const ReminderLogModel(
      id: 'fallback-log-id',
      reminderId: 'fallback-reminder-id',
      date: '2026-01-01',
      scheduledTime: '09:00',
      status: 'taken',
      takenAt: null,
    ),
  );
}

// This helper creates a reminder model for tests.
ReminderModel makeReminder({
  String id = 'r1',
  String title = 'Panadol',
  String subtitle = '1 tablet',
  String time = '09:00',
  bool isEnabled = true,
}) {
  return ReminderModel(
    id: id,
    title: title,
    subtitle: subtitle,
    time: time,
    isEnabled: isEnabled,
  );
}

// This helper creates a reminder log model for tests.
ReminderLogModel makeLog({
  String id = 'log1',
  String reminderId = 'r1',
  String date = '2026-01-01',
  String scheduledTime = '09:00',
  String status = 'taken',
  String? takenAt,
}) {
  return ReminderLogModel(
    id: id,
    reminderId: reminderId,
    date: date,
    scheduledTime: scheduledTime,
    status: status,
    takenAt: takenAt,
  );
}

// This helper returns a future time in HH:mm format.
String futureTimeString({int minutesAhead = 60}) {
  final dt = DateTime.now().add(Duration(minutes: minutesAhead));
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

// This helper returns a past time in HH:mm format.
String pastTimeString({int minutesBehind = 60}) {
  final dt = DateTime.now().subtract(Duration(minutes: minutesBehind));
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

// This helper builds a localized app wrapper for widget and integration tests.
Widget buildMedicalRemindersTestApp({
  required Widget child,
  MedicalRemindersViewModel? viewModel,
  Locale locale = const Locale('en'),
}) {
  Widget wrapped = MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizationDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
    ],
    home: Scaffold(body: child),
  );

  if (viewModel != null) {
    wrapped = ChangeNotifierProvider<MedicalRemindersViewModel>.value(
      value: viewModel,
      child: wrapped,
    );
  }

  return wrapped;
}

// This helper pumps a widget with localization and optional view model.
Future<void> pumpMedicalRemindersWidget(
    WidgetTester tester, {
      required Widget child,
      MedicalRemindersViewModel? viewModel,
      Locale locale = const Locale('en'),
    }) async {
  await tester.pumpWidget(
    buildMedicalRemindersTestApp(
      child: child,
      viewModel: viewModel,
      locale: locale,
    ),
  );
}