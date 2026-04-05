import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/emergency_contact_model.dart';
import '../models/emergency_profile_model.dart';
import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';
import '../services/emergency_profile_service.dart';
import '../services/emergency_share_service.dart';
import '../services/emergency_whatsapp_service.dart';

class EmergencyActiveEmergencyViewModel extends ChangeNotifier {
  EmergencyActiveEmergencyViewModel({
    required EmergencyProfileService profileService,
    required EmergencyContactsService contactsService,
    required EmergencyLocationService locationService,
    required EmergencyDialerService dialerService,
    required EmergencyShareService shareService,
    required EmergencyWhatsAppService whatsappService,
  })  : _profileService = profileService,
        _contactsService = contactsService,
        _locationService = locationService,
        _dialerService = dialerService,
        _shareService = shareService,
        _whatsappService = whatsappService;

  final EmergencyProfileService _profileService;
  final EmergencyContactsService _contactsService;
  final EmergencyLocationService _locationService;
  final EmergencyDialerService _dialerService;
  final EmergencyShareService _shareService;
  final EmergencyWhatsAppService _whatsappService;

  bool isLoading = false;
  String? errorMessage;

  EmergencyProfileModel? profile;
  List<EmergencyContactModel> contacts = [];

  Position? currentPosition;
  String? currentLocationUrl;

  bool get isLocationAvailable => currentPosition != null;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1) حمّل البيانات الأساسية مع بعض
      final profileFuture = _profileService.getProfile();
      final contactsFuture = _contactsService.getContacts();

      profile = await profileFuture;
      contacts = await contactsFuture;

      // 2) افتح الشاشة بسرعة
      isLoading = false;
      notifyListeners();

      // 3) وبعدها حمّل الموقع في الخلفية
      currentPosition = await _locationService.getCurrentPositionSafely();

      if (currentPosition != null) {
        currentLocationUrl =
            _locationService.buildGoogleMapsUrl(currentPosition!);
      } else {
        currentLocationUrl = null;
      }

      notifyListeners();
    } catch (_) {
      errorMessage = 'تعذر تحميل بيانات حالة الطوارئ.';
      isLoading = false;
      notifyListeners();
    }
  }

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

  String buildEmergencyShareText() {
    final buffer = StringBuffer();

    buffer.writeln('أنا في حالة طوارئ.');
    buffer.writeln();

    if (profile != null) {
      if (profile!.fullName.trim().isNotEmpty) {
        buffer.writeln('الاسم: ${profile!.fullName}');
      }

      if (profile!.disabilityType.trim().isNotEmpty) {
        buffer.writeln('نوع الإعاقة: ${profile!.disabilityType}');
      }

      buffer.writeln('ملاحظة التواصل: $communicationMethodLabel');

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

    if (currentLocationUrl != null) {
      buffer.writeln();
      buffer.writeln('موقعي الحالي:');
      buffer.writeln(currentLocationUrl);
    } else {
      buffer.writeln();
      buffer.writeln('الموقع الحالي غير متاح الآن.');
    }

    return buffer.toString().trim();
  }

  Future<void> shareEmergencyStatus() async {
    final text = buildEmergencyShareText();

    await _shareService.shareText(
      text: text,
      subject: 'Qudra Emergency Alert',
    );
  }

  Future<void> sendUrgentWhatsAppAlert() async {
    final text = buildEmergencyShareText();

    EmergencyContactModel? targetContact;

    if (contacts.isNotEmpty) {
      try {
        targetContact = contacts.firstWhere(
              (contact) => contact.isPrimary,
        );
      } catch (_) {
        targetContact = contacts.first;
      }
    }

    if (targetContact == null) {
      await shareEmergencyStatus();
      return;
    }

    final opened = await _whatsappService.openChatWithPrefilledMessage(
      rawPhoneNumber: targetContact.phoneNumber,
      message: text,
    );

    if (!opened) {
      await shareEmergencyStatus();
    }
  }

  Future<void> callUnifiedEmergency() async {
    await _dialerService.callNumber('112');
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
}