import 'package:flutter/material.dart';
import '../models/emergency_profile_model.dart';
import '../services/emergency_profile_service.dart';

class EmergencyProfileSetupViewModel extends ChangeNotifier {
  EmergencyProfileSetupViewModel({
    required EmergencyProfileService profileService,
  }) : _profileService = profileService {
    fullNameController = TextEditingController();
    medicalNotesController = TextEditingController();
    allergiesAndMedicationsController = TextEditingController();
  }

  final EmergencyProfileService _profileService;

  late final TextEditingController fullNameController;
  late final TextEditingController medicalNotesController;
  late final TextEditingController allergiesAndMedicationsController;

  String? selectedDisabilityType;
  String? selectedBloodType;
  EmergencyCommunicationMethod selectedCommunicationMethod =
      EmergencyCommunicationMethod.text;
  bool vibrationOnAlert = true;

  bool isLoading = false;
  bool hasLoadedInitialData = false;

  String? fullNameError;
  String? disabilityTypeError;
  String? bloodTypeError;
  String? submitError;

  // This list stores localization keys for the disability type options.
  List<String> get disabilityTypes => const [
    'disability_hearing',
    'disability_visual',
    'disability_physical',
    'emergency_disability_speech',
    'emergency_disability_mental',
    'disability_other',
  ];

  List<String> get bloodTypes => const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // This helper normalizes old saved values to the new localization keys.
  String? _normalizeDisabilityType(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    switch (raw.trim()) {
      case 'سمعية':
      case 'Hearing':
        return 'disability_hearing';
      case 'بصرية':
      case 'Visual':
        return 'disability_visual';
      case 'حركية':
      case 'Physical':
        return 'disability_physical';
      case 'نطقية':
      case 'Speech':
        return 'emergency_disability_speech';
      case 'ذهنية':
      case 'Mental':
        return 'emergency_disability_mental';
      case 'أخرى':
      case 'Other':
        return 'disability_other';
      default:
        return raw.trim();
    }
  }

  Future<void> loadInitialData() async {
    if (hasLoadedInitialData) return;

    isLoading = true;
    notifyListeners();

    final existingProfile = await _profileService.getProfile();
    if (existingProfile != null) {
      fullNameController.text = existingProfile.fullName;
      medicalNotesController.text = existingProfile.importantMedicalNotes;
      allergiesAndMedicationsController.text =
          existingProfile.allergiesAndMedications;
      selectedDisabilityType =
          _normalizeDisabilityType(existingProfile.disabilityType);
      selectedBloodType =
      existingProfile.bloodType.isEmpty ? null : existingProfile.bloodType;
      selectedCommunicationMethod =
          existingProfile.preferredCommunicationMethod;
      vibrationOnAlert = existingProfile.vibrationOnAlert;
    }

    hasLoadedInitialData = true;
    isLoading = false;
    notifyListeners();
  }

  void updateDisabilityType(String? value) {
    selectedDisabilityType = value;
    disabilityTypeError = null;
    notifyListeners();
  }

  void updateBloodType(String? value) {
    selectedBloodType = value;
    bloodTypeError = null;
    notifyListeners();
  }

  void updateCommunicationMethod(EmergencyCommunicationMethod method) {
    selectedCommunicationMethod = method;
    notifyListeners();
  }

  void updateVibrationOnAlert(bool value) {
    vibrationOnAlert = value;
    notifyListeners();
  }

  void clearSubmitError() {
    submitError = null;
    notifyListeners();
  }

  bool validateForm() {
    final fullName = fullNameController.text.trim();

    // These error keys are resolved to localized text by the UI.
    fullNameError =
    fullName.isEmpty ? 'emergency_validation_full_name' : null;
    disabilityTypeError = (selectedDisabilityType == null ||
        selectedDisabilityType!.trim().isEmpty)
        ? 'emergency_validation_disability_type'
        : null;
    bloodTypeError = (selectedBloodType == null ||
        selectedBloodType!.trim().isEmpty)
        ? 'emergency_validation_blood_type'
        : null;

    notifyListeners();
    return fullNameError == null &&
        disabilityTypeError == null &&
        bloodTypeError == null;
  }

  EmergencyProfileModel buildProfile() {
    return EmergencyProfileModel(
      fullName: fullNameController.text.trim(),
      disabilityType: selectedDisabilityType?.trim() ?? '',
      bloodType: selectedBloodType?.trim() ?? '',
      preferredCommunicationMethod: selectedCommunicationMethod,
      importantMedicalNotes: medicalNotesController.text.trim(),
      allergiesAndMedications:
      allergiesAndMedicationsController.text.trim(),
      vibrationOnAlert: vibrationOnAlert,
      isSetupCompleted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<bool> saveProfile() async {
    clearSubmitError();
    final isValid = validateForm();
    if (!isValid) return false;

    isLoading = true;
    notifyListeners();

    try {
      final profile = buildProfile();
      await _profileService.saveProfile(profile);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      // This error key is resolved to localized text by the UI.
      submitError = 'emergency_profile_save_error';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    medicalNotesController.dispose();
    allergiesAndMedicationsController.dispose();
    super.dispose();
  }
}