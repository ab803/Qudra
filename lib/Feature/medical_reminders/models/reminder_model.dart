// This enum defines the supported care plan item types used by reminders.
enum CarePlanType {
  medication,
  feeding,
  rehab,
  learning,
}

// This extension converts care plan enum values to stable database strings.
extension CarePlanTypeX on CarePlanType {
  String get value {
    switch (this) {
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

  // This helper converts a stored database string back to a CarePlanType.
  static CarePlanType fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'feeding':
        return CarePlanType.feeding;
      case 'rehab':
        return CarePlanType.rehab;
      case 'learning':
        return CarePlanType.learning;
      case 'medication':
      default:
        return CarePlanType.medication;
    }
  }
}

class ReminderModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final bool isEnabled;

  // This field identifies whether this reminder is medication, feeding, rehab, or learning.
  final CarePlanType type;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isEnabled,
    this.type = CarePlanType.medication,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    bool? isEnabled,
    CarePlanType? type,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'isEnabled': isEnabled ? 1 : 0,

      // This stores the care plan item type in SQLite as a stable text value.
      'type': type.value,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      time: (map['time'] as String?) ?? '',
      isEnabled: (map['isEnabled'] as int) == 1,

      // This keeps old reminder rows safe by defaulting missing/null types to medication.
      type: CarePlanTypeX.fromValue(map['type'] as String?),
    );
  }
}