enum ReminderDoseStatus {
  taken,
  skipped,
  missed,
}

extension ReminderDoseStatusX on ReminderDoseStatus {
  String get value {
    switch (this) {
      case ReminderDoseStatus.taken:
        return 'taken';
      case ReminderDoseStatus.skipped:
        return 'skipped';
      case ReminderDoseStatus.missed:
        return 'missed';
    }
  }

  static ReminderDoseStatus fromValue(String value) {
    switch (value) {
      case 'taken':
        return ReminderDoseStatus.taken;
      case 'skipped':
        return ReminderDoseStatus.skipped;
      case 'missed':
        return ReminderDoseStatus.missed;
      default:
        return ReminderDoseStatus.missed;
    }
  }
}

class ReminderLogModel {
  final String id;
  final String reminderId;
  final String date; // yyyy-MM-dd
  final String scheduledTime; // HH:mm
  final String status; // taken / skipped / missed
  final String? takenAt; // ISO string (optional)

  const ReminderLogModel({
    required this.id,
    required this.reminderId,
    required this.date,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
  });

  ReminderLogModel copyWith({
    String? id,
    String? reminderId,
    String? date,
    String? scheduledTime,
    String? status,
    String? takenAt,
  }) {
    return ReminderLogModel(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      takenAt: takenAt ?? this.takenAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'date': date,
      'scheduledTime': scheduledTime,
      'status': status,
      'takenAt': takenAt,
    };
  }

  factory ReminderLogModel.fromMap(Map<String, dynamic> map) {
    return ReminderLogModel(
      id: map['id'] as String,
      reminderId: map['reminderId'] as String,
      date: map['date'] as String,
      scheduledTime: map['scheduledTime'] as String,
      status: map['status'] as String,
      takenAt: map['takenAt'] as String?,
    );
  }
}
