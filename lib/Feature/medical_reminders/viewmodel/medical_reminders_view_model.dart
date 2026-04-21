import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../models/reminder_log_model.dart';
import '../services/reminder_service.dart';
import '../services/reminder_log_service.dart';
import '../services/local_notification_service.dart';
import '../utils/time_format_validator.dart';
import '../utils/date_time_helpers.dart';

class MedicalRemindersViewModel extends ChangeNotifier {
  final ReminderService _service;
  final ReminderLogService _logService = ReminderLogService();

  MedicalRemindersViewModel(this._service);

  List<ReminderModel> _reminders = [];
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);

  List<ReminderLogModel> _todayLogs = [];
  List<ReminderLogModel> get todayLogs => List.unmodifiable(_todayLogs);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get totalCount => _reminders.length;

  int get dueTodayCount => _reminders.where(_isDueToday).length;

  int get takenTodayCount => _reminders.where((r) {
    return _isDueToday(r) &&
        getTodayStatusForReminder(r.id) == ReminderDoseStatus.taken;
  }).length;

  int get missedTodayCount => _reminders.where((r) {
    return _isDueToday(r) &&
        getTodayStatusForReminder(r.id) == ReminderDoseStatus.missed;
  }).length;

  double get adherencePercent {
    if (dueTodayCount == 0) return 0;
    return takenTodayCount / dueTodayCount;
  }

  String? get nextReminderTime {
    final now = DateTime.now();

    final upcoming = _reminders
        .where((r) {
      if (!_isDueToday(r)) return false;

      final status = getTodayStatusForReminder(r.id);
      if (status == ReminderDoseStatus.taken ||
          status == ReminderDoseStatus.skipped ||
          status == ReminderDoseStatus.missed) {
        return false;
      }

      final dt = DateTimeHelpers.scheduledDateTimeToday(r.time);
      return dt != null && dt.isAfter(now);
    })
        .toList()
      ..sort((a, b) {
        final da = DateTimeHelpers.scheduledDateTimeToday(a.time)!;
        final db = DateTimeHelpers.scheduledDateTimeToday(b.time)!;
        return da.compareTo(db);
      });

    if (upcoming.isEmpty) return null;
    return upcoming.first.time;
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminders = await _service.getAllReminders();
      await _loadTodayLogs();
      await _syncAutoMissedLogs();
    } catch (e) {
      _errorMessage = 'Failed to load reminders';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTodayLogs() async {
    _todayLogs = await _logService.getLogsByDate(DateTimeHelpers.todayKey());
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _errorMessage = null;
    notifyListeners();

    // ✅ Updated:
    // Enforce required valid time even if someone bypasses the add sheet UI.
    if (!TimeFormatValidator.isValidHHmm(reminder.time)) {
      _errorMessage = 'Please choose a valid reminder time';
      notifyListeners();
      return;
    }

    try {
      await _service.createReminder(reminder);
      _reminders = await _service.getAllReminders();
      await _loadTodayLogs();
      await _syncAutoMissedLogs();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add reminder';
      notifyListeners();
      return;
    }

    await LocalNotificationService.instance.scheduleReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    _errorMessage = null;

    final oldReminders = List<ReminderModel>.from(_reminders);
    final oldLogs = List<ReminderLogModel>.from(_todayLogs);

    _reminders.removeWhere((r) => r.id == id);
    _todayLogs.removeWhere((l) => l.reminderId == id);
    notifyListeners();

    try {
      await _service.deleteReminder(id);
      await _logService.deleteLogsForReminder(id);
    } catch (e) {
      _reminders = oldReminders;
      _todayLogs = oldLogs;
      _errorMessage = 'Failed to delete reminder';
      notifyListeners();
      return;
    }

    await LocalNotificationService.instance.cancelReminder(id);
  }

  Future<void> toggleEnabled(String id, bool enabled) async {
    _errorMessage = null;

    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final old = _reminders[index];
    _reminders[index] = old.copyWith(isEnabled: enabled);
    notifyListeners();

    try {
      await _service.setEnabled(id, enabled);
      await _syncAutoMissedLogs();
    } catch (e) {
      _reminders[index] = old;
      _errorMessage = 'Failed to update status';
      notifyListeners();
      return;
    }

    if (!enabled) {
      await LocalNotificationService.instance.cancelReminder(id);
    } else {
      await LocalNotificationService.instance
          .scheduleReminder(old.copyWith(isEnabled: true));
    }

    notifyListeners();
  }

  Future<void> markTaken(String reminderId) async {
    final reminder = _findReminder(reminderId);
    if (reminder == null || !_isDueToday(reminder)) return;

    final log = ReminderLogModel(
      id: DateTimeHelpers.generateLogId(reminderId),
      reminderId: reminderId,
      date: DateTimeHelpers.todayKey(),
      scheduledTime: reminder.time,
      status: ReminderDoseStatus.taken.value,
      takenAt: DateTime.now().toIso8601String(),
    );

    try {
      await _logService.upsertLog(log);
      await _loadTodayLogs();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark dose as taken';
      notifyListeners();
    }
  }

  Future<void> skipDose(String reminderId) async {
    final reminder = _findReminder(reminderId);
    if (reminder == null || !_isDueToday(reminder)) return;

    final log = ReminderLogModel(
      date: DateTimeHelpers.todayKey(),
      reminderId: reminderId,
      id: DateTimeHelpers.generateLogId(reminderId),
      scheduledTime: reminder.time,
      status: ReminderDoseStatus.skipped.value,
      takenAt: null,
    );

    try {
      await _logService.upsertLog(log);
      await _loadTodayLogs();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to skip dose';
      notifyListeners();
    }
  }

  ReminderDoseStatus? getTodayStatusForReminder(String reminderId) {
    final reminder = _findReminder(reminderId);
    if (reminder == null || !_isDueToday(reminder)) return null;

    final log = _findTodayLogForReminder(reminderId);
    if (log != null) {
      return ReminderDoseStatusX.fromValue(log.status);
    }

    final scheduled = DateTimeHelpers.scheduledDateTimeToday(reminder.time);
    if (scheduled == null) return null;

    if (scheduled.isBefore(DateTime.now())) {
      return ReminderDoseStatus.missed;
    }

    return null;
  }

  String? getStatusLabelForReminder(String reminderId) {
    final status = getTodayStatusForReminder(reminderId);

    switch (status) {
      case ReminderDoseStatus.taken:
        return 'Taken today';
      case ReminderDoseStatus.skipped:
        return 'Skipped today';
      case ReminderDoseStatus.missed:
        return 'Missed';
      default:
        return null;
    }
  }

  ReminderLogModel? _findTodayLogForReminder(String reminderId) {
    try {
      return _todayLogs.firstWhere((l) => l.reminderId == reminderId);
    } catch (_) {
      return null;
    }
  }

  ReminderModel? _findReminder(String id) {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  bool _isDueToday(ReminderModel reminder) {
    return reminder.isEnabled && TimeFormatValidator.isValidHHmm(reminder.time);
  }

  Future<void> _syncAutoMissedLogs() async {
    final now = DateTime.now();
    bool insertedAny = false;

    for (final reminder in _reminders) {
      if (!_isDueToday(reminder)) continue;

      final existing = _findTodayLogForReminder(reminder.id);
      if (existing != null) continue;

      final scheduled = DateTimeHelpers.scheduledDateTimeToday(reminder.time);
      if (scheduled == null) continue;

      if (scheduled.isBefore(now)) {
        final missedLog = ReminderLogModel(
          id: DateTimeHelpers.generateLogId(reminder.id),
          reminderId: reminder.id,
          date: DateTimeHelpers.todayKey(),
          scheduledTime: reminder.time,
          status: ReminderDoseStatus.missed.value,
          takenAt: null,
        );

        await _logService.upsertLog(missedLog);
        insertedAny = true;
      }
    }

    if (insertedAny) {
      await _loadTodayLogs();
    }
  }
}