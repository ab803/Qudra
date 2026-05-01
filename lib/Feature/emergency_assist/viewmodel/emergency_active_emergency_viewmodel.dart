import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import '../services/emergency_profile_service.dart';
import '../services/emergency_share_service.dart';
import '../services/emergency_whatsapp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/Services/Localization/ar.dart';
import '../../../core/Services/Localization/en.dart';
import '../models/emergency_contact_model.dart';
import '../models/emergency_profile_model.dart';
import '../services/emergency_contacts_service.dart';
import '../services/emergency_dialer_service.dart';
import '../services/emergency_location_service.dart';


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

  // This key reuses the same saved language preference used by the app language cubit.
  static const String _languageKey = 'app_language';

  bool isLoading = false;
  String? errorMessage;
  EmergencyProfileModel? profile;
  List<EmergencyContactModel> contacts = [];
  Position? currentPosition;
  String? currentLocationUrl;

  bool get isLocationAvailable => currentPosition != null;

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
      // 1) Load the base emergency data first.
      final profileFuture = _profileService.getProfile();
      final contactsFuture = _contactsService.getContacts();

      profile = await profileFuture;
      contacts = await contactsFuture;

      // 2) Show the screen immediately after loading base data.
      isLoading = false;
      notifyListeners();

      // 3) Then fetch the location in the background.
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
      errorMessage = 'emergency_active_load_error';
      isLoading = false;
      notifyListeners();
    }
  }

  // This helper returns the localized value for a given key based on the saved language or system locale.
  Future<String> _translate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey);

    final localeCode = (savedCode == null || savedCode == 'system')
        ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
        : savedCode;

    final values = localeCode == 'ar' ? ar : en;
    return values[key] ?? key;
  }

  // This helper safely localizes stored disability values that may already be plain Arabic or English text.
  Future<String> _localizeDisabilityType(String rawValue) async {
    final normalized = rawValue.trim();

    switch (normalized) {
      case 'سمعية':
      case 'Hearing':
        return await _translate('disability_hearing');
      case 'بصرية':
      case 'Visual':
        return await _translate('disability_visual');
      case 'حركية':
      case 'Physical':
        return await _translate('disability_physical');
      case 'نطقية':
      case 'Speech':
        return await _translate('emergency_disability_speech');
      case 'ذهنية':
      case 'Mental':
        return await _translate('emergency_disability_mental');
      case 'أخرى':
      case 'Other':
        return await _translate('disability_other');
      default:
        return await _translate(normalized);
    }
  }

  Future<String> buildEmergencyShareText() async {
    final buffer = StringBuffer();

    // This intro line is localized for active emergency sharing.
    buffer.writeln(await _translate('emergency_share_intro_active'));
    buffer.writeln();

    if (profile != null) {
      if (profile!.fullName.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('full_name')}: ${profile!.fullName}',
        );
      }

      if (profile!.disabilityType.trim().isNotEmpty) {
        buffer.writeln(
          '${await _translate('disability_type')}: ${await _localizeDisabilityType(profile!.disabilityType)}',
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

    buffer.writeln();

    if (currentLocationUrl != null) {
      buffer.writeln(await _translate('emergency_current_location'));
      buffer.writeln(currentLocationUrl);
    } else {
      buffer.writeln(await _translate('emergency_location_unavailable'));
    }

    return buffer.toString().trim();
  }

  Future<void> shareEmergencyStatus() async {
    final text = await buildEmergencyShareText();

    await _shareService.shareText(
      text: text,
      subject: await _translate('emergency_alert_share_subject'),
    );
  }

  Future<void> sendUrgentWhatsAppAlert() async {
    final text = await buildEmergencyShareText();

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
