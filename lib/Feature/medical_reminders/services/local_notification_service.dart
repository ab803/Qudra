import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../utils/time_format_validator.dart';
import '../models/reminder_model.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance =
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = 'med_reminders_v2';
  static const String _channelName = 'Medical Reminders';
  static const String _channelDesc =
      'Notifications for medicine reminders';

  bool _initialized = false;

  // ---------------------------
  // INIT
  // ---------------------------
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz_data.initializeTimeZones();
    } catch (e) {
      debugPrint('TZ init failed: $e');
    }

    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (resp) {},
      );
    } catch (e) {
      debugPrint('Notifications initialize failed: $e');
    }

    // Channel
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
    );

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } catch (e) {
      debugPrint('Create channel failed: $e');
    }

    // Android 13+ permission
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {}

    // Exact alarms permission
    final androidImpl =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final bool canExact =
        await androidImpl?.canScheduleExactNotifications() ?? false;

    if (!canExact) {
      await androidImpl?.requestExactAlarmsPermission();
    }

    // iOS permissions
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {}

    _initialized = true;
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    return const NotificationDetails(android: android, iOS: ios);
  }

  // ---------------------------
  // Helper: Convert ID
  // ---------------------------
  int _notifIdFromString(String id) {
    final parsed = int.tryParse(id);
    if (parsed != null) {
      final mod = parsed % 2147483647;
      return mod == 0 ? 1 : mod;
    }

    final h = id.hashCode & 0x7fffffff;
    return h == 0 ? 1 : h;
  }


  // ---------------------------
  // Schedule Reminder
  // ---------------------------
  Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!reminder.isEnabled) return;

    final hhmm = TimeFormatValidator.normalizeToHHmm(reminder.time);
    if (hhmm == null) return;

    try {
      await scheduleDaily(
        notificationId: _notifIdFromString(reminder.id),
        title: reminder.title,
        body: reminder.subtitle,
        hhmm: hhmm,
        payload: reminder.id,
      );
    } catch (e) {}
  }

  // ---------------------------
  // Cancel Reminder
  // ---------------------------
  Future<void> cancelReminder(String reminderId) async {
    try {
      await cancel(_notifIdFromString(reminderId));
    } catch (e) {}
  }

  // ---------------------------
  // Daily scheduling
  // ---------------------------
  Future<bool> scheduleDaily({
    required int notificationId,
    required String title,
    required String body,
    required String hhmm,
    String? payload,
  }) async {
    await init();

    try {
      final parts = hhmm.split(':');
      if (parts.length != 2) return false;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: _details(),
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ---------------------------
  // Cancel by ID
  // ---------------------------
  Future<void> cancel(int notificationId) async {
    await init();
    try {
      await _plugin.cancel(id: notificationId);
    } catch (e) {}
  }
}