import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/emergency_assist/models/emergency_contact_model.dart';
import 'package:qudra_0/Feature/emergency_assist/models/emergency_profile_model.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_contacts_service.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_dialer_service.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_location_service.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_profile_service.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_share_service.dart';
import 'package:qudra_0/Feature/emergency_assist/services/emergency_whatsapp_service.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';

// This mock simulates emergency profile service behavior in tests.
class MockEmergencyProfileService extends Mock
    implements EmergencyProfileService {}

// This mock simulates emergency contacts service behavior in tests.
class MockEmergencyContactsService extends Mock
    implements EmergencyContactsService {}

// This mock simulates emergency location service behavior in tests.
class MockEmergencyLocationService extends Mock
    implements EmergencyLocationService {}

// This mock simulates emergency dialer behavior in tests.
class MockEmergencyDialerService extends Mock
    implements EmergencyDialerService {}

// This mock simulates share service behavior in tests.
class MockEmergencyShareService extends Mock
    implements EmergencyShareService {}

// This mock simulates WhatsApp service behavior in tests.
class MockEmergencyWhatsAppService extends Mock
    implements EmergencyWhatsAppService {}

// This helper registers fallback values required by mocktail.
void registerEmergencyAssistFallbackValues() {
  registerFallbackValue(
    const EmergencyContactModel(
      localId: 1,
      name: 'Fallback Contact',
      relation: 'Friend',
      phoneNumber: '01000000000',
      isPrimary: true,
    ),
  );

  registerFallbackValue(
    EmergencyProfileModel(
      localId: 1,
      fullName: 'Fallback User',
      disabilityType: 'disability_hearing',
      bloodType: 'O+',
      preferredCommunicationMethod: EmergencyCommunicationMethod.text,
      importantMedicalNotes: 'None',
      allergiesAndMedications: 'None',
      vibrationOnAlert: true,
      isSetupCompleted: true,
    ),
  );
}

// This helper creates a contact model for tests.
EmergencyContactModel makeEmergencyContact({
  int? localId = 1,
  String name = 'Ahmed',
  String relation = 'Friend',
  String phoneNumber = '01012345678',
  bool isPrimary = true,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return EmergencyContactModel(
    localId: localId,
    name: name,
    relation: relation,
    phoneNumber: phoneNumber,
    isPrimary: isPrimary,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// This helper creates an emergency profile model for tests.
EmergencyProfileModel makeEmergencyProfile({
  int? localId = 1,
  String fullName = 'Ahmed Ayman',
  String disabilityType = 'disability_hearing',
  String bloodType = 'O+',
  EmergencyCommunicationMethod preferredCommunicationMethod =
      EmergencyCommunicationMethod.text,
  String importantMedicalNotes = 'Asthma',
  String allergiesAndMedications = 'Penicillin',
  bool vibrationOnAlert = true,
  bool isSetupCompleted = true,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return EmergencyProfileModel(
    localId: localId,
    fullName: fullName,
    disabilityType: disabilityType,
    bloodType: bloodType,
    preferredCommunicationMethod: preferredCommunicationMethod,
    importantMedicalNotes: importantMedicalNotes,
    allergiesAndMedications: allergiesAndMedications,
    vibrationOnAlert: vibrationOnAlert,
    isSetupCompleted: isSetupCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// This helper builds a localized test app wrapper.
Widget buildEmergencyAssistTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizationDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
    ],
    home: Scaffold(body: child),
  );
}

// This helper pumps a widget with localization support.
Future<void> pumpEmergencyAssistWidget(
    WidgetTester tester, {
      required Widget child,
      Locale locale = const Locale('en'),
    }) async {
  await tester.pumpWidget(
    buildEmergencyAssistTestApp(
      child: child,
      locale: locale,
    ),
  );
}