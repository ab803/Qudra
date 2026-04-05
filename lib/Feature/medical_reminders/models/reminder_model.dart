class ReminderModel {
  final String id;
  final String title;
  final String subtitle;
  final String? time;
  final bool isEnabled;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.time,
    required this.isEnabled,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    bool? isEnabled,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      time: map['time'] as String?,
      isEnabled: (map['isEnabled'] as int) == 1,
    );
  }
}