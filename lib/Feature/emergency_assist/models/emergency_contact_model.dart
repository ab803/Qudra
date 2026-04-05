class EmergencyContactModel {
  final int? localId;
  final String name;
  final String relation;
  final String phoneNumber;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmergencyContactModel({
    this.localId,
    required this.name,
    required this.relation,
    required this.phoneNumber,
    required this.isPrimary,
    this.createdAt,
    this.updatedAt,
  });

  EmergencyContactModel copyWith({
    int? localId,
    String? name,
    String? relation,
    String? phoneNumber,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContactModel(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'name': name,
      'relation': relation,
      'phone_number': phoneNumber,
      'is_primary': isPrimary ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      localId: json['local_id'] as int?,
      name: (json['name'] ?? '') as String,
      relation: (json['relation'] ?? '') as String,
      phoneNumber: (json['phone_number'] ?? '') as String,
      isPrimary: (json['is_primary'] ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}