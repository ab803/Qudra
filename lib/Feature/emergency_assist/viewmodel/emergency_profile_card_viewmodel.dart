import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/Services/Localization/ar.dart';
import '../../../core/Services/Localization/en.dart';
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

  static const String _languageKey = 'app_language';

  bool isLoading = false;
  String? errorMessage;
  EmergencyProfileModel? profile;
  List<EmergencyContactModel> contacts = [];
  Position? currentPosition;
  String? currentLocationUrl;

  bool get hasProfile => profile != null;
  bool get hasContacts => contacts.isNotEmpty;
  bool get isLocationAvailable => currentLocationUrl != null;

  // This getter returns a localization key for the preferred communication method.
  String get communicationMethodLabelKey {
    final method = profile?.preferredCommunicationMethod;
    switch (method) {
      case EmergencyCommunicationMethod.text:
        return 'emergency_communication_note_text';
      case EmergencyCommunicationMethod.signLanguage:
        return 'emergency_communication_note_sign';
      case EmergencyCommunicationMethod.voice:
        return 'emergency_communication_note_voice';
      default:
        return 'emergency_communication_note_default';
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
      // This error key is resolved to localized text by the UI.
      errorMessage = 'emergency_profile_card_load_error';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _translate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey);

    final localeCode = (savedCode == null || savedCode == 'system')
        ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
        : savedCode;

    final values = localeCode == 'ar' ? ar : en;
    return values[key] ?? key;
  }

  Future<String> buildCardShareText() async {
    final buffer = StringBuffer();
    buffer.writeln(await _translate('emergency_card_title'));
    buffer.writeln();

    if (profile != null) {
      if (profile!.fullName.trim().isNotEmpty) {
        buffer.writeln('${await _translate('full_name')}: ${profile!.fullName}');
      }
      if (profile!.disabilityType.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('disability_type')}: ${await _translate(profile!.disabilityType)}',
        );
      }
      buffer.writeln(
        '${await _translate('emergency_preferred_communication')}: ${await _translate(communicationMethodLabelKey)}',
      );
      if (profile!.bloodType.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('emergency_blood_type')}: ${profile!.bloodType}',
        );
      }
      if (profile!.importantMedicalNotes.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('emergency_important_medical_notes')}: ${profile!.importantMedicalNotes}',
        );
      }
      if (profile!.allergiesAndMedications.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('emergency_allergies_medications')}: ${profile!.allergiesAndMedications}',
        );
      }
    }

    if (contacts.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(await _translate('emergency_contacts_title'));
      for (final contact in contacts.take(3)) {
        final primaryMark = contact.isPrimary
            ? ' (${await _translate('emergency_contact_primary')})'
            : '';
        buffer.writeln(
          '- ${contact.name} - ${contact.relation}$primaryMark - ${contact.phoneNumber}',
        );
      }
    }

    if (currentLocationUrl != null) {
      buffer.writeln();
      buffer.writeln(await _translate('emergency_current_location'));
      buffer.writeln(currentLocationUrl);
    }

    return buffer.toString().trim();
  }

  Future<void> shareCard() async {
    await _shareService.shareText(
      text: await buildCardShareText(),
      subject: await _translate('emergency_card_share_subject'),
    );
  }

  Future<void> callContact(String phoneNumber) async {
    await _dialerService.callNumber(phoneNumber);
  }
}