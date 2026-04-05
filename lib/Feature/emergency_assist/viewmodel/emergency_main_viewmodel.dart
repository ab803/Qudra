import 'package:flutter/material.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_profile_model.dart';
import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';

class EmergencyMainViewModel extends ChangeNotifier {
  EmergencyMainViewModel({
    required EmergencyProfileService profileService,
    required EmergencyContactsService contactsService,
    required EmergencyLocationService locationService,
    required EmergencyDialerService dialerService,
  })  : _profileService = profileService,
        _contactsService = contactsService,
        _locationService = locationService,
        _dialerService = dialerService;

  final EmergencyProfileService _profileService;
  final EmergencyContactsService _contactsService;
  final EmergencyLocationService _locationService;
  final EmergencyDialerService _dialerService;

  bool isLoading = false;

  EmergencyProfileModel? profile;
  List<EmergencyContactModel> contacts = [];

  bool isLocationServiceEnabled = false;
  bool isLocationPermissionGranted = false;

  final Set<String> selectedQuickNeeds = {};

  List<String> get quickNeeds => const [
    'لا أستطيع التحدث',
    'ضعف سمع',
    'حالة طبية',
    'أحتاج مقدم رعاية',
    'أنا في خطر',
    'أحتاج مساعدة الآن',
  ];

  bool get hasContacts => contacts.isNotEmpty;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _profileService.getProfile();
      contacts = await _contactsService.getContacts();
      isLocationServiceEnabled =
      await _locationService.isLocationServiceEnabled();
      isLocationPermissionGranted =
      await _locationService.isPermissionGranted();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleQuickNeed(String label) {
    if (selectedQuickNeeds.contains(label)) {
      selectedQuickNeeds.remove(label);
    } else {
      selectedQuickNeeds.add(label);
    }
    notifyListeners();
  }

  Future<void> callPolice() async {
    await _dialerService.callNumber('122');
  }

  Future<void> callAmbulance() async {
    await _dialerService.callNumber('123');
  }

  Future<void> callFire() async {
    await _dialerService.callNumber('180');
  }

  Future<void> callContact(String phoneNumber) async {
    await _dialerService.callNumber(phoneNumber);
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
