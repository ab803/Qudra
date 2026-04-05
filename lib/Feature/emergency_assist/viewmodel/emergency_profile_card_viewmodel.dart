import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/emergency_contact_model.dart';
import '../models/emergency_profile_model.dart';
import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../services/emergency_share_service.dart';

class EmergencyProfileCardViewModel extends ChangeNotifier {
  EmergencyProfileCardViewModel({
    required EmergencyProfileService profileService,
    required EmergencyContactsService contactsService,
    required EmergencyLocationService locationService,
    required EmergencyShareService shareService,
    required EmergencyDialerService dialerService,
  })  : _profileService = profileService,
        _contactsService = contactsService,
        _locationService = locationService,
        _shareService = shareService,
        _dialerService = dialerService;

  final EmergencyProfileService _profileService;
  final EmergencyContactsService _contactsService;
  final EmergencyLocationService _locationService;
  final EmergencyShareService _shareService;
  final EmergencyDialerService _dialerService;

  bool isLoading = false;
  String? errorMessage;

  EmergencyProfileModel? profile;
  List<EmergencyContactModel> contacts = [];

  Position? currentPosition;
  String? currentLocationUrl;

  bool get hasProfile => profile != null;
  bool get hasContacts => contacts.isNotEmpty;
  bool get isLocationAvailable => currentLocationUrl != null;

  String get communicationMethodLabel {
    final method = profile?.preferredCommunicationMethod;

    switch (method) {
      case EmergencyCommunicationMethod.text:
        return 'يرجى التواصل كتابة';
      case EmergencyCommunicationMethod.signLanguage:
        return 'أستخدم لغة الإشارة';
      case EmergencyCommunicationMethod.voice:
        return 'أفضل التواصل الصوتي';
      default:
        return 'يرجى التواصل بطريقة مناسبة';
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1) حمّل الملف الشخصي والكونتاكتس أولًا مع بعض
      final profileFuture = _profileService.getProfile();
      final contactsFuture = _contactsService.getContacts();

      profile = await profileFuture;
      contacts = await contactsFuture;

      // 2) افتح البطاقة فورًا
      isLoading = false;
      notifyListeners();

      // 3) وبعدها هات الموقع في الخلفية
      currentPosition = await _locationService.getCurrentPositionSafely();

      if (currentPosition != null) {
        currentLocationUrl =
            _locationService.buildGoogleMapsUrl(currentPosition!);
      } else {
        currentLocationUrl = null;
      }

      notifyListeners();
    } catch (_) {
      errorMessage = 'تعذر تحميل بطاقة الطوارئ.';
      isLoading = false;
      notifyListeners();
    }
  }

  String buildCardShareText() {
    final buffer = StringBuffer();

    buffer.writeln('بطاقة طوارئ');
    buffer.writeln();

    if (profile != null) {
      if (profile!.fullName.trim().isNotEmpty) {
        buffer.writeln('الاسم: ${profile!.fullName}');
      }

      if (profile!.disabilityType.trim().isNotEmpty) {
        buffer.writeln('نوع الإعاقة: ${profile!.disabilityType}');
      }

      buffer.writeln('التواصل المناسب: $communicationMethodLabel');

      if (profile!.bloodType.trim().isNotEmpty) {
        buffer.writeln('فصيلة الدم: ${profile!.bloodType}');
      }

      if (profile!.importantMedicalNotes.trim().isNotEmpty) {
        buffer.writeln('ملاحظات طبية: ${profile!.importantMedicalNotes}');
      }

      if (profile!.allergiesAndMedications.trim().isNotEmpty) {
        buffer.writeln(
          'الحساسية والأدوية: ${profile!.allergiesAndMedications}',
        );
      }
    }

    if (contacts.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('جهات اتصال الطوارئ:');

      for (final contact in contacts.take(3)) {
        final primaryMark = contact.isPrimary ? ' (أساسي)' : '';
        buffer.writeln(
          '- ${contact.name} - ${contact.relation}$primaryMark - ${contact.phoneNumber}',
        );
      }
    }

    if (currentLocationUrl != null) {
      buffer.writeln();
      buffer.writeln('الموقع الحالي:');
      buffer.writeln(currentLocationUrl);
    }

    return buffer.toString().trim();
  }

  Future<void> shareCard() async {
    await _shareService.shareText(
      text: buildCardShareText(),
      subject: 'Qudra Emergency Profile Card',
    );
  }

  Future<void> callContact(String phoneNumber) async {
    await _dialerService.callNumber(phoneNumber);
  }
}