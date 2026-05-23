import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/models/service_model.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_cubit.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_state.dart';

import 'Test_helpers.dart';

void main() {
  group('Unit › InstitutionModel', () {
    // This test verifies InstitutionModel parses json correctly.
    test('fromJson returns expected institution values', () {
      final model = InstitutionModel.fromJson({
        'id': 'inst-10',
        'name': 'Ability Center',
        'email': 'ability@example.com',
        'phone': '01011111111',
        'address': 'Giza',
        'description': 'Institution description',
        'institution_type': 'Rehab Center',
        'location': 'https://maps.google.com/?q=giza',
        'created_at': '2026-05-20T12:00:00.000Z',
      });

      expect(model.id, 'inst-10');
      expect(model.name, 'Ability Center');
      expect(model.email, 'ability@example.com');
      expect(model.phone, '01011111111');
      expect(model.address, 'Giza');
      expect(model.description, 'Institution description');
      expect(model.institutionType, 'Rehab Center');
      expect(model.location, 'https://maps.google.com/?q=giza');
      expect(model.createdAt, isNotNull);
    });
  });

  group('Unit › InstitutionServiceModel', () {
    // This test verifies InstitutionServiceModel parses full json correctly.
    test('fromJson returns expected full service values', () {
      final model = InstitutionServiceModel.fromJson({
        'id': 'srv-1',
        'institution_id': 'inst-1',
        'name': 'Speech Therapy',
        'category': 'Therapy',
        'description': 'Service description',
        'supported_disabilities': ['Hearing', 'Speech'],
        'price': 200,
        'is_free': false,
        'duration_minutes': 45,
        'location_mode': 'on_site',
        'booking_type': 'instant_slot',
        'availability_notes': 'Notes here',
        'working_days': ['Sunday', 'Monday'],
        'working_start_time': '09:00:00',
        'working_end_time': '17:00:00',
        'is_active': true,
        'created_at': '2026-05-20T12:00:00.000Z',
      });

      expect(model.id, 'srv-1');
      expect(model.institutionId, 'inst-1');
      expect(model.name, 'Speech Therapy');
      expect(model.category, 'Therapy');
      expect(model.description, 'Service description');
      expect(model.supportedDisabilities, ['Hearing', 'Speech']);
      expect(model.price, 200);
      expect(model.isFree, false);
      expect(model.durationMinutes, 45);
      expect(model.locationMode, 'on_site');
      expect(model.bookingType, 'instant_slot');
      expect(model.workingDays, ['Sunday', 'Monday']);
      expect(model.workingStartTime, '09:00:00');
      expect(model.workingEndTime, '17:00:00');
      expect(model.isActive, true);
      expect(model.createdAt, isNotNull);
    });

    // This test verifies service defaults are applied for missing optional fields.
    test('fromJson applies defaults for missing optional fields', () {
      final model = InstitutionServiceModel.fromJson({
        'id': 'srv-2',
        'institution_id': 'inst-2',
        'name': 'Basic Service',
        'category': 'General',
        'price': 0,
      });

      expect(model.supportedDisabilities, isEmpty);
      expect(model.isFree, false);
      expect(model.durationMinutes, 30);
      expect(model.locationMode, 'on_site');
      expect(model.bookingType, 'instant_slot');
      expect(model.workingDays, isEmpty);
      expect(model.isActive, true);
    });
  });

  group('Unit › InstitutionCubit', () {
    late MockInstitutionFeatureService service;
    late InstitutionCubit cubit;

    setUp(() {
      service = MockInstitutionFeatureService();
      cubit = InstitutionCubit(service);
    });

    blocTest<InstitutionCubit, InstitutionState>(
      'emits [InstitutionLoading, InstitutionsLoaded] when loadInstitutions succeeds',
      build: () {
        when(() => service.fetchInstitutions()).thenAnswer(
              (_) async => [
            makeInstitution(id: 'inst-1', name: 'Hope Center'),
            makeInstitution(id: 'inst-2', name: 'Care Center'),
          ],
        );
        when(() => service.fetchInstitutionDisabilityMap()).thenAnswer(
              (_) async => {
            'inst-1': ['Hearing'],
            'inst-2': ['Visual'],
          },
        );
        return cubit;
      },
      act: (cubit) => cubit.loadInstitutions(),
      expect: () => [
        isA<InstitutionLoading>(),
        isA<InstitutionsLoaded>()
            .having((state) => state.institutions.length, 'institutions length', 2)
            .having(
              (state) => state.supportedDisabilitiesByInstitution['inst-1'],
          'disability map for inst-1',
          ['Hearing'],
        ),
      ],
    );

    blocTest<InstitutionCubit, InstitutionState>(
      'emits [InstitutionLoading, InstitutionError] when loadInstitutions fails',
      build: () {
        when(() => service.fetchInstitutions())
            .thenThrow(Exception('failed to load'));
        when(() => service.fetchInstitutionDisabilityMap())
            .thenAnswer((_) async => {});
        return cubit;
      },
      act: (cubit) => cubit.loadInstitutions(),
      expect: () => [
        isA<InstitutionLoading>(),
        isA<InstitutionError>(),
      ],
    );

    blocTest<InstitutionCubit, InstitutionState>(
      'emits [InstitutionLoading, InstitutionDetailsLoaded] when loadInstitutionDetails succeeds',
      build: () {
        when(() => service.fetchInstitutionById('inst-1')).thenAnswer(
              (_) async => makeInstitution(id: 'inst-1', name: 'Hope Center'),
        );
        when(() => service.fetchInstitutionServices('inst-1')).thenAnswer(
              (_) async => [
            makeInstitutionService(
              institutionId: 'inst-1',
              name: 'Speech Therapy',
            ),
          ],
        );
        return cubit;
      },
      act: (cubit) => cubit.loadInstitutionDetails('inst-1'),
      expect: () => [
        isA<InstitutionLoading>(),
        isA<InstitutionDetailsLoaded>()
            .having((state) => state.institution.id, 'institution id', 'inst-1')
            .having((state) => state.services.length, 'services length', 1),
      ],
    );

    blocTest<InstitutionCubit, InstitutionState>(
      'emits [InstitutionLoading, InstitutionError] when loadInstitutionDetails fails',
      build: () {
        when(() => service.fetchInstitutionById('inst-error'))
            .thenThrow(Exception('details error'));
        return cubit;
      },
      act: (cubit) => cubit.loadInstitutionDetails('inst-error'),
      expect: () => [
        isA<InstitutionLoading>(),
        isA<InstitutionError>(),
      ],
    );
  });
}