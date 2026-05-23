import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/emergency_assist/models/emergency_contact_model.dart';
import 'package:qudra_0/Feature/emergency_assist/models/emergency_profile_model.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_contacts_viewmodel.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_entry_viewmodel.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_main_viewmodel.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_profile_setup_viewmodel.dart';
import 'package:qudra_0/Feature/emergency_assist/viewmodel/emergency_sos_activation_viewmodel.dart';

import 'Test_helpers.dart';

void main() {
  // This setup registers mocktail fallback values once.
  setUpAll(() {
    registerEmergencyAssistFallbackValues();
  });

  group('Unit › EmergencyContactModel', () {
    // This test verifies toJson serializes the contact correctly.
    test('toJson returns expected values', () {
      final contact = makeEmergencyContact(
        localId: 7,
        name: 'Mona',
        relation: 'Sister',
        phoneNumber: '01011111111',
        isPrimary: false,
      );

      final json = contact.toJson();

      expect(json['local_id'], 7);
      expect(json['name'], 'Mona');
      expect(json['relation'], 'Sister');
      expect(json['phone_number'], '01011111111');
      expect(json['is_primary'], 0);
    });

    // This test verifies fromJson restores the same contact data.
    test('fromJson parses contact correctly', () {
      final contact = EmergencyContactModel.fromJson({
        'local_id': 5,
        'name': 'Ali',
        'relation': 'Father',
        'phone_number': '01012345678',
        'is_primary': 1,
      });

      expect(contact.localId, 5);
      expect(contact.name, 'Ali');
      expect(contact.relation, 'Father');
      expect(contact.phoneNumber, '01012345678');
      expect(contact.isPrimary, true);
    });

    // This test verifies copyWith only updates provided fields.
    test('copyWith updates selected fields only', () {
      final original = makeEmergencyContact();
      final updated = original.copyWith(name: 'Updated', isPrimary: false);

      expect(updated.localId, original.localId);
      expect(updated.name, 'Updated');
      expect(updated.relation, original.relation);
      expect(updated.phoneNumber, original.phoneNumber);
      expect(updated.isPrimary, false);
    });
  });

  group('Unit › EmergencyProfileModel', () {
    // This test verifies profile serialization.
    test('toJson returns expected profile values', () {
      final profile = makeEmergencyProfile(
        fullName: 'Sara',
        disabilityType: 'disability_visual',
        bloodType: 'A+',
        preferredCommunicationMethod:
        EmergencyCommunicationMethod.signLanguage,
      );

      final json = profile.toJson();

      expect(json['full_name'], 'Sara');
      expect(json['disability_type'], 'disability_visual');
      expect(json['blood_type'], 'A+');
      expect(json['preferred_communication_method'], 'signLanguage');
      expect(json['is_setup_completed'], 1);
      expect(json['vibration_on_alert'], 1);
    });

    // This test verifies profile parsing from json.
    test('fromJson parses profile correctly', () {
      final profile = EmergencyProfileModel.fromJson({
        'local_id': 1,
        'full_name': 'Omar',
        'disability_type': 'disability_physical',
        'blood_type': 'B+',
        'preferred_communication_method': 'voice',
        'important_medical_notes': 'None',
        'allergies_and_medications': 'None',
        'vibration_on_alert': 0,
        'is_setup_completed': 1,
      });

      expect(profile.fullName, 'Omar');
      expect(profile.disabilityType, 'disability_physical');
      expect(profile.bloodType, 'B+');
      expect(profile.preferredCommunicationMethod,
          EmergencyCommunicationMethod.voice);
      expect(profile.vibrationOnAlert, false);
      expect(profile.isSetupCompleted, true);
    });

    // This test verifies the empty factory defaults.
    test('empty returns a non-completed default profile', () {
      final profile = EmergencyProfileModel.empty();

      expect(profile.fullName, '');
      expect(profile.disabilityType, '');
      expect(profile.bloodType, '');
      expect(profile.preferredCommunicationMethod,
          EmergencyCommunicationMethod.text);
      expect(profile.isSetupCompleted, false);
      expect(profile.vibrationOnAlert, true);
    });
  });

  group('Unit › EmergencyEntryViewModel', () {
    late MockEmergencyProfileService profileService;
    late MockEmergencyLocationService locationService;
    late EmergencyEntryViewModel viewModel;

    setUp(() {
      profileService = MockEmergencyProfileService();
      locationService = MockEmergencyLocationService();

      viewModel = EmergencyEntryViewModel(
        profileService: profileService,
        locationService: locationService,
      );
    });

    // This test verifies profile setup is required when setup is incomplete.
    test('initialize returns needProfileSetup when setup is incomplete',
            () async {
          when(() => profileService.hasCompletedSetup()).thenAnswer((_) async => false);

          await viewModel.initialize();

          expect(viewModel.status, EmergencyEntryStatus.needProfileSetup);
        });

    // This test verifies location permission screen appears when service is disabled.
    test('initialize returns needLocationPermission when location service is disabled',
            () async {
          when(() => profileService.hasCompletedSetup()).thenAnswer((_) async => true);
          when(() => locationService.isLocationServiceEnabled())
              .thenAnswer((_) async => false);

          await viewModel.initialize();

          expect(viewModel.status, EmergencyEntryStatus.needLocationPermission);
          expect(viewModel.isLocationServiceDisabled, true);
          expect(viewModel.permissionHelperMessage,
              'location_service_disabled_message');
        });

    // This test verifies ready state when setup and permission are complete.
    test('initialize returns ready when setup and permission are available',
            () async {
          when(() => profileService.hasCompletedSetup()).thenAnswer((_) async => true);
          when(() => locationService.isLocationServiceEnabled())
              .thenAnswer((_) async => true);
          when(() => locationService.isPermissionGranted())
              .thenAnswer((_) async => true);

          await viewModel.initialize();

          expect(viewModel.status, EmergencyEntryStatus.ready);
        });

    // This test verifies permission request updates state to ready when granted.
    test('requestLocationPermission returns ready when granted', () async {
      when(() => locationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => locationService.requestLocationPermission())
          .thenAnswer((_) async => true);

      await viewModel.requestLocationPermission();

      expect(viewModel.status, EmergencyEntryStatus.ready);
      expect(viewModel.isRequestingPermission, false);
    });
  });

  group('Unit › EmergencyContactsViewModel', () {
    late MockEmergencyContactsService contactsService;
    late MockEmergencyDialerService dialerService;
    late EmergencyContactsViewModel viewModel;

    setUp(() {
      contactsService = MockEmergencyContactsService();
      dialerService = MockEmergencyDialerService();

      viewModel = EmergencyContactsViewModel(
        contactsService: contactsService,
        dialerService: dialerService,
      );
    });

    // This test verifies contact loading works successfully.
    test('loadContacts populates contacts list on success', () async {
      when(() => contactsService.getContacts())
          .thenAnswer((_) async => [makeEmergencyContact(name: 'Ali')]);

      await viewModel.loadContacts();

      expect(viewModel.contacts.length, 1);
      expect(viewModel.contacts.first.name, 'Ali');
      expect(viewModel.errorMessage, isNull);
    });

    // This test verifies adding a contact reloads the list.
    test('addContact returns true and reloads contacts on success', () async {
      final contact = makeEmergencyContact(name: 'Mona');

      when(() => contactsService.addContact(any())).thenAnswer((_) async {});
      when(() => contactsService.getContacts())
          .thenAnswer((_) async => [contact]);

      final result = await viewModel.addContact(contact);

      expect(result, true);
      expect(viewModel.contacts.length, 1);
      verify(() => contactsService.addContact(any())).called(1);
    });

    // This test verifies update failure sets the correct error key.
    test('updateContact returns false and sets error on failure', () async {
      when(() => contactsService.updateContact(any()))
          .thenThrow(Exception('update failed'));

      final result = await viewModel.updateContact(makeEmergencyContact());

      expect(result, false);
      expect(viewModel.errorMessage, 'emergency_contact_update_error');
    });

    // This test verifies callContact uses the dialer service.
    test('callContact forwards call to dialer service', () async {
      when(() => dialerService.callNumber('01012345678')).thenAnswer((_) async {});

      await viewModel.callContact('01012345678');

      verify(() => dialerService.callNumber('01012345678')).called(1);
    });
  });

  group('Unit › EmergencyMainViewModel', () {
    late MockEmergencyProfileService profileService;
    late MockEmergencyContactsService contactsService;
    late MockEmergencyLocationService locationService;
    late MockEmergencyDialerService dialerService;
    late EmergencyMainViewModel viewModel;

    setUp(() {
      profileService = MockEmergencyProfileService();
      contactsService = MockEmergencyContactsService();
      locationService = MockEmergencyLocationService();
      dialerService = MockEmergencyDialerService();

      viewModel = EmergencyMainViewModel(
        profileService: profileService,
        contactsService: contactsService,
        locationService: locationService,
        dialerService: dialerService,
      );
    });

    // This test verifies loadData populates profile, contacts, and location flags.
    test('loadData fills all dashboard data', () async {
      when(() => profileService.getProfile())
          .thenAnswer((_) async => makeEmergencyProfile());
      when(() => contactsService.getContacts())
          .thenAnswer((_) async => [makeEmergencyContact()]);
      when(() => locationService.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => locationService.isPermissionGranted())
          .thenAnswer((_) async => false);

      await viewModel.loadData();

      expect(viewModel.profile, isNotNull);
      expect(viewModel.contacts.length, 1);
      expect(viewModel.isLocationServiceEnabled, true);
      expect(viewModel.isLocationPermissionGranted, false);
    });

    // This test verifies quick needs can be toggled on and off.
    test('toggleQuickNeed adds and removes selected need', () {
      const key = 'quick_need_in_danger';

      viewModel.toggleQuickNeed(key);
      expect(viewModel.selectedQuickNeeds.contains(key), true);

      viewModel.toggleQuickNeed(key);
      expect(viewModel.selectedQuickNeeds.contains(key), false);
    });

    // This test verifies police call uses the expected emergency number.
    test('callPolice calls 122', () async {
      when(() => dialerService.callNumber('122')).thenAnswer((_) async {});

      await viewModel.callPolice();

      verify(() => dialerService.callNumber('122')).called(1);
    });
  });

  group('Unit › EmergencyProfileSetupViewModel', () {
    late MockEmergencyProfileService profileService;
    late EmergencyProfileSetupViewModel viewModel;

    setUp(() {
      profileService = MockEmergencyProfileService();
      viewModel = EmergencyProfileSetupViewModel(
        profileService: profileService,
      );
    });

    // This test verifies validation errors appear when required fields are missing.
    test('validateForm sets required field errors when fields are empty', () {
      final result = viewModel.validateForm();

      expect(result, false);
      expect(viewModel.fullNameError, 'emergency_validation_full_name');
      expect(
        viewModel.disabilityTypeError,
        'emergency_validation_disability_type',
      );
      expect(viewModel.bloodTypeError, 'emergency_validation_blood_type');
    });

    // This test verifies saveProfile succeeds with valid data.
    test('saveProfile returns true and saves valid profile', () async {
      viewModel.fullNameController.text = 'Ahmed';
      viewModel.updateDisabilityType('disability_hearing');
      viewModel.updateBloodType('O+');

      when(() => profileService.saveProfile(any())).thenAnswer((_) async {});

      final result = await viewModel.saveProfile();

      expect(result, true);
      expect(viewModel.submitError, isNull);
      verify(() => profileService.saveProfile(any())).called(1);
    });

    // This test verifies saveProfile failure sets the submit error.
    test('saveProfile returns false and sets submitError on failure', () async {
      viewModel.fullNameController.text = 'Ahmed';
      viewModel.updateDisabilityType('disability_hearing');
      viewModel.updateBloodType('O+');

      when(() => profileService.saveProfile(any()))
          .thenThrow(Exception('save failed'));

      final result = await viewModel.saveProfile();

      expect(result, false);
      expect(viewModel.submitError, 'emergency_profile_save_error');
    });
  });

  group('Unit › EmergencySosActivationViewModel', () {
    // This test verifies countdown completes automatically after the configured time.
    test('startCountdown completes after totalMilliseconds', () async {
      final viewModel = EmergencySosActivationViewModel(totalMilliseconds: 300);

      viewModel.startCountdown();
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(viewModel.isCompleted, true);
      expect(viewModel.isRunning, false);
      expect(viewModel.remainingMilliseconds, 0);
    });

    // This test verifies cancel resets countdown state.
    test('cancelCountdown resets state correctly', () async {
      final viewModel = EmergencySosActivationViewModel(totalMilliseconds: 500);

      viewModel.startCountdown();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      viewModel.cancelCountdown();

      expect(viewModel.isCancelled, true);
      expect(viewModel.isCompleted, false);
      expect(viewModel.isRunning, false);
      expect(viewModel.remainingMilliseconds, 500);
    });
  });
}