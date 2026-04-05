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

  List<String> get disabilityTypes => const [
    'سمعية',
    'بصرية',
    'حركية',
    'نطقية',
    'ذهنية',
    'أخرى',
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
      selectedDisabilityType = existingProfile.disabilityType.isEmpty
          ? null
          : existingProfile.disabilityType;
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

    fullNameError =
    fullName.isEmpty ? 'من فضلك أدخل الاسم الكامل' : null;

    disabilityTypeError = (selectedDisabilityType == null ||
        selectedDisabilityType!.trim().isEmpty)
        ? 'من فضلك اختر نوع الإعاقة'
        : null;

    bloodTypeError =
    (selectedBloodType == null || selectedBloodType!.trim().isEmpty)
        ? 'من فضلك اختر فصيلة الدم'
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
      submitError = 'حدث خطأ أثناء حفظ البيانات، حاول مرة أخرى.';
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