import 'package:flutter_test/flutter_test.dart';
import 'package:qudra_0/core/Models/people_with_disabilityModel.dart';

void main() {
  // ─── Fixture ────────────────────────────────────────────────────────────────
  final tCreatedAt = DateTime(2024, 6, 1, 12, 0, 0);

  final tModel = PeopleWithDisabilityModel(
    id: 'user-123',
    createdAt: tCreatedAt,
    fullName: 'Ahmed Ali',
    phone: '01012345678',
    email: 'ahmed@example.com',
    disabilityType: 'Visual',
    password: 'secret123',
    responsiblePerson: 'Mohamed Ali',
    gender: 'Male',
    age: 25,
  );

  final tJson = {
    'id': 'user-123',
    'created_at': tCreatedAt.toIso8601String(),
    'full_name': 'Ahmed Ali',
    'phone': '01012345678',
    'email': 'ahmed@example.com',
    'disability_type': 'Visual',
    'password': 'secret123',
    'responsible_person': 'Mohamed Ali',
    'gender': 'Male',
    'age': 25,
  };

  // ─── fromJson ───────────────────────────────────────────────────────────────
  group('fromJson', () {
    test('maps all fields correctly from a Supabase response', () {
      final result = PeopleWithDisabilityModel.fromJson(tJson);

      expect(result.id, 'user-123');
      expect(result.fullName, 'Ahmed Ali');
      expect(result.phone, '01012345678');
      expect(result.email, 'ahmed@example.com');
      expect(result.disabilityType, 'Visual');
      expect(result.password, 'secret123');
      expect(result.responsiblePerson, 'Mohamed Ali');
      expect(result.gender, 'Male');
      expect(result.age, 25);
      expect(result.createdAt, tCreatedAt);
    });

    test('parses createdAt as UTC DateTime', () {
      final result = PeopleWithDisabilityModel.fromJson(tJson);
      expect(result.createdAt, isA<DateTime>());
      // Supabase ISO strings round-trip correctly
      expect(result.createdAt.toIso8601String(),
          tCreatedAt.toIso8601String());
    });

    test('throws when a required field is missing', () {
      final badJson = Map<String, dynamic>.from(tJson)..remove('full_name');
      expect(
            () => PeopleWithDisabilityModel.fromJson(badJson),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when age is the wrong type', () {
      final badJson = Map<String, dynamic>.from(tJson)
        ..['age'] = 'not-a-number';
      expect(
            () => PeopleWithDisabilityModel.fromJson(badJson),
        throwsA(isA<TypeError>()),
      );
    });
  });

  // ─── toJson ─────────────────────────────────────────────────────────────────
  group('toJson', () {
    test('produces the exact map Supabase expects', () {
      expect(tModel.toJson(), equals(tJson));
    });

    test('serialises createdAt using toIso8601String', () {
      final json = tModel.toJson();
      expect(json['created_at'], tCreatedAt.toIso8601String());
    });

    test('fromJson(toJson()) round-trips without data loss', () {
      final roundTripped =
      PeopleWithDisabilityModel.fromJson(tModel.toJson());

      expect(roundTripped.id, tModel.id);
      expect(roundTripped.fullName, tModel.fullName);
      expect(roundTripped.email, tModel.email);
      expect(roundTripped.age, tModel.age);
      expect(roundTripped.gender, tModel.gender);
      expect(roundTripped.disabilityType, tModel.disabilityType);
    });
  });

  // ─── copyWith ───────────────────────────────────────────────────────────────
  group('copyWith', () {
    test('returns an equal copy when no fields are overridden', () {
      final copy = tModel.copyWith();

      expect(copy.id, tModel.id);
      expect(copy.fullName, tModel.fullName);
      expect(copy.email, tModel.email);
      expect(copy.age, tModel.age);
    });

    test('overrides only the provided field', () {
      final copy = tModel.copyWith(fullName: 'Sara Ahmed');

      expect(copy.fullName, 'Sara Ahmed');
      // All other fields unchanged
      expect(copy.id, tModel.id);
      expect(copy.email, tModel.email);
      expect(copy.age, tModel.age);
    });

    test('does not mutate the original', () {
      tModel.copyWith(age: 99);
      expect(tModel.age, 25); // original unchanged
    });

    test('can override multiple fields at once', () {
      final copy = tModel.copyWith(phone: '01099999999', age: 30);

      expect(copy.phone, '01099999999');
      expect(copy.age, 30);
      expect(copy.fullName, tModel.fullName);
    });

    test('can override gender and disabilityType', () {
      final copy = tModel.copyWith(
        gender: 'Female',
        disabilityType: 'Hearing',
      );

      expect(copy.gender, 'Female');
      expect(copy.disabilityType, 'Hearing');
    });
  });

  // ─── toString ───────────────────────────────────────────────────────────────
  group('toString', () {
    test('contains key identifying fields', () {
      final str = tModel.toString();
      expect(str, contains('user-123'));
      expect(str, contains('Ahmed Ali'));
      expect(str, contains('ahmed@example.com'));
    });
  });
}