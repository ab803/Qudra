import 'dart:convert';

enum EmergencyCommunicationMethod {
  text,
  signLanguage,
  voice,
}

class EmergencyProfileModel {
  final int? localId;
  final String fullName;
  final String disabilityType;
  final String bloodType;
  final EmergencyCommunicationMethod preferredCommunicationMethod;
  final String importantMedicalNotes;
  final String allergiesAndMedications;
  final bool vibrationOnAlert;
  final bool isSetupCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmergencyProfileModel({
    this.localId,
    required this.fullName,
    required this.disabilityType,
    required this.bloodType,
    required this.preferredCommunicationMethod,
    required this.importantMedicalNotes,
    required this.allergiesAndMedications,
    required this.vibrationOnAlert,
    required this.isSetupCompleted,
    this.createdAt,
    this.updatedAt,
  });

  EmergencyProfileModel copyWith({
    int? localId,
    String? fullName,
    String? disabilityType,
    String? bloodType,
    EmergencyCommunicationMethod? preferredCommunicationMethod,
    String? importantMedicalNotes,
    String? allergiesAndMedications,
    bool? vibrationOnAlert,
    bool? isSetupCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyProfileModel(
      localId: localId ?? this.localId,
      fullName: fullName ?? this.fullName,
      disabilityType: disabilityType ?? this.disabilityType,
      bloodType: bloodType ?? this.bloodType,
      preferredCommunicationMethod:
      preferredCommunicationMethod ?? this.preferredCommunicationMethod,
      importantMedicalNotes:
      importantMedicalNotes ?? this.importantMedicalNotes,
      allergiesAndMedications:
      allergiesAndMedications ?? this.allergiesAndMedications,
      vibrationOnAlert: vibrationOnAlert ?? this.vibrationOnAlert,
      isSetupCompleted: isSetupCompleted ?? this.isSetupCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'full_name': fullName,
      'disability_type': disabilityType,
      'blood_type': bloodType,
      'preferred_communication_method': preferredCommunicationMethod.name,
      'important_medical_notes': importantMedicalNotes,
      'allergies_and_medications': allergiesAndMedications,
      'vibration_on_alert': vibrationOnAlert ? 1 : 0,
      'is_setup_completed': isSetupCompleted ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory EmergencyProfileModel.fromJson(Map<String, dynamic> json) {
    return EmergencyProfileModel(
      localId: json['local_id'] as int?,
      fullName: (json['full_name'] ?? '') as String,
      disabilityType: (json['disability_type'] ?? '') as String,
      bloodType: (json['blood_type'] ?? '') as String,
      preferredCommunicationMethod: EmergencyCommunicationMethod.values.firstWhere(
            (method) =>
        method.name == json['preferred_communication_method'],
        orElse: () => EmergencyCommunicationMethod.text,
      ),
      importantMedicalNotes:
      (json['important_medical_notes'] ?? '') as String,
      allergiesAndMedications:
      (json['allergies_and_medications'] ?? '') as String,
      vibrationOnAlert: (json['vibration_on_alert'] ?? 1) == 1,
      isSetupCompleted: (json['is_setup_completed'] ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  String toRawJson() => jsonEncode(toJson());

  factory EmergencyProfileModel.fromRawJson(String source) =>
      EmergencyProfileModel.fromJson(jsonDecode(source));

  static EmergencyProfileModel empty() {
    return const EmergencyProfileModel(
      fullName: '',
      disabilityType: '',
      bloodType: '',
      preferredCommunicationMethod: EmergencyCommunicationMethod.text,
      importantMedicalNotes: '',
      allergiesAndMedications: '',
      vibrationOnAlert: true,
      isSetupCompleted: false,
    );
  }
}
