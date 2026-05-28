import 'package:flutter/foundation.dart';

import '../models/reminder_model.dart';
import '../models/reminder_log_model.dart';
import '../services/reminder_service.dart';
import '../services/reminder_log_service.dart';
import '../services/local_notification_service.dart';
import '../utils/time_format_validator.dart';
import '../utils/date_time_helpers.dart';

// This enum defines the visible filter tabs used by the Care Plans screen.
enum CarePlanFilter {
  all,
  medication,
  feeding,
  rehab,
  learning,
}

// This extension converts each filter into a localization key and matching care plan type.
extension CarePlanFilterX on CarePlanFilter {
  String get labelKey {
    switch (this) {
      case CarePlanFilter.all:
        return 'plan_type_all';
      case CarePlanFilter.medication:
        return 'plan_type_medication';
      case CarePlanFilter.feeding:
        return 'plan_type_feeding';
      case CarePlanFilter.rehab:
        return 'plan_type_rehab';
      case CarePlanFilter.learning:
        return 'plan_type_learning';
    }
  }

  CarePlanType? get matchingType {
    switch (this) {
      case CarePlanFilter.all:
        return null;
      case CarePlanFilter.medication:
        return CarePlanType.medication;
      case CarePlanFilter.feeding:
        return CarePlanType.feeding;
      case CarePlanFilter.rehab:
        return CarePlanType.rehab;
      case CarePlanFilter.learning:
        return CarePlanType.learning;
    }
  }
}

// This view model manages reminders, care plans, today logs, and UI state.
class MedicalRemindersViewModel extends ChangeNotifier {
  final ReminderService _service;
  final ReminderLogService _logService;
  final LocalNotificationService _notificationService;

  // This constructor allows injecting dependencies for testing.
  MedicalRemindersViewModel(
      this._service, {
        ReminderLogService? logService,
        LocalNotificationService? notificationService,
      })  : _logService = logService ?? ReminderLogService(),
        _notificationService =
            notificationService ?? LocalNotificationService.instance;

  List<ReminderModel> _reminders = [];

  // This getter returns all care plan items regardless of the selected filter.
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);

  List<ReminderLogModel> _todayLogs = [];

  // This getter returns today's logs for all care plan items.
  List<ReminderLogModel> get todayLogs => List.unmodifiable(_todayLogs);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // This field stores the currently selected Care Plans filter.
  CarePlanFilter _selectedFilter = CarePlanFilter.all;

  CarePlanFilter get selectedFilter => _selectedFilter;

  // This getter exposes all filters for the UI chips row.
  List<CarePlanFilter> get availableFilters => const [
    CarePlanFilter.all,
    CarePlanFilter.medication,
    CarePlanFilter.feeding,
    CarePlanFilter.rehab,
    CarePlanFilter.learning,
  ];

  // This method updates the selected filter and refreshes the visible list.
  void setSelectedFilter(CarePlanFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
  }

  // This getter returns reminders filtered by the selected care plan type.
  List<ReminderModel> get visibleReminders {
    final matchingType = _selectedFilter.matchingType;

    if (matchingType == null) {
      return List.unmodifiable(_reminders);
    }

    return List.unmodifiable(
      _reminders.where((reminder) => reminder.type == matchingType).toList(),
    );
  }

  // This getter returns the total number of all care plan items.
  int get totalCount => _reminders.length;

  // This getter returns the number of active items due today across all care plan types.
  int get dueTodayCount => _reminders.where(_isDueToday).length;

  // This getter returns the number of completed items today across all care plan types.
  int get takenTodayCount => _reminders.where((r) {
    return _isDueToday(r) &&
        getTodayStatusForReminder(r.id) == ReminderDoseStatus.taken;
  }).length;

  // This getter returns the number of missed items today across all care plan types.
  int get missedTodayCount => _reminders.where((r) {
    return _isDueToday(r) &&
        getTodayStatusForReminder(r.id) == ReminderDoseStatus.missed;
  }).length;

  // This getter returns adherence percentage for today's due care plan items.
  double get adherencePercent {
    if (dueTodayCount == 0) return 0;
    return takenTodayCount / dueTodayCount;
  }

  // This getter returns the next upcoming reminder time for today across all care plan items.
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

  // This method loads reminders, today logs, and missed care plan items.
  Future<void> loadReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reminders = await _service.getAllReminders();
      await _loadTodayLogs();
      await _syncAutoMissedLogs();
    } catch (e) {
      // This error key is resolved to localized text by the UI.
      _errorMessage = 'failed_load_reminders';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method loads all reminder logs for today.
  Future<void> _loadTodayLogs() async {
    _todayLogs = await _logService.getLogsByDate(DateTimeHelpers.todayKey());
  }

  // This method adds a care plan item and schedules its notification.
  Future<void> addReminder(ReminderModel reminder) async {
    _errorMessage = null;
    notifyListeners();

    // This block validates time format before creating the care plan item.
    if (!TimeFormatValidator.isValidHHmm(reminder.time)) {
      _errorMessage = 'valid_reminder_time';
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
      _errorMessage = 'failed_add_reminder';
      notifyListeners();
      return;
    }

    await _notificationService.scheduleReminder(reminder);
  }

  // This method deletes a care plan item and removes related logs and notifications.
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
      _errorMessage = 'failed_delete_reminder';
      notifyListeners();
      return;
    }

    await _notificationService.cancelReminder(id);
  }

  // This method toggles care plan item enabled state and updates notifications.
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
      _errorMessage = 'failed_update_reminder_status';
      notifyListeners();
      return;
    }

    if (!enabled) {
      await _notificationService.cancelReminder(id);
    } else {
      await _notificationService.scheduleReminder(
        old.copyWith(isEnabled: true),
      );
    }

    notifyListeners();
  }

  // This method marks today's care plan item as completed.
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
      _errorMessage = 'failed_mark_taken';
      notifyListeners();
    }
  }

  // This method marks today's care plan item as skipped.
  Future<void> skipDose(String reminderId) async {
    final reminder = _findReminder(reminderId);
    if (reminder == null || !_isDueToday(reminder)) return;

    final log = ReminderLogModel(
      id: DateTimeHelpers.generateLogId(reminderId),
      reminderId: reminderId,
      date: DateTimeHelpers.todayKey(),
      scheduledTime: reminder.time,
      status: ReminderDoseStatus.skipped.value,
      takenAt: null,
    );

    try {
      await _logService.upsertLog(log);
      await _loadTodayLogs();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'failed_skip_dose';
      notifyListeners();
    }
  }

  // This method returns today's status for a care plan item.
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

  // This method returns the localized status key used by the UI.
  String? getStatusLabelForReminder(String reminderId) {
    final status = getTodayStatusForReminder(reminderId);

    switch (status) {
      case ReminderDoseStatus.taken:
        return 'status_taken_today';
      case ReminderDoseStatus.skipped:
        return 'status_skipped_today';
      case ReminderDoseStatus.missed:
        return 'status_missed';
      default:
        return null;
    }
  }

  // This helper returns the localization key for a care plan type.
  String getTypeLabelKey(CarePlanType type) {
    switch (type) {
      case CarePlanType.medication:
        return 'plan_type_medication';
      case CarePlanType.feeding:
        return 'plan_type_feeding';
      case CarePlanType.rehab:
        return 'plan_type_rehab';
      case CarePlanType.learning:
        return 'plan_type_learning';
    }
  }

  // This helper returns a semantic icon key for a care plan type.
  String getTypeIconKey(CarePlanType type) {
    switch (type) {
      case CarePlanType.medication:
        return 'medication';
      case CarePlanType.feeding:
        return 'feeding';
      case CarePlanType.rehab:
        return 'rehab';
      case CarePlanType.learning:
        return 'learning';
    }
  }

  // This helper finds today's log for a care plan item.
  ReminderLogModel? _findTodayLogForReminder(String reminderId) {
    try {
      return _todayLogs.firstWhere((l) => l.reminderId == reminderId);
    } catch (_) {
      return null;
    }
  }

  // This helper finds a care plan item by id.
  ReminderModel? _findReminder(String id) {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // This helper checks whether a care plan item is valid and enabled for today.
  bool _isDueToday(ReminderModel reminder) {
    return reminder.isEnabled && TimeFormatValidator.isValidHHmm(reminder.time);
  }

  // This method auto-creates missed logs for overdue care plan items with no status yet.
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