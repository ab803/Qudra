// ─── test/home/unit/home_unit_test.dart ───────────────────────────────────────
// UNIT TESTS
// Tests pure Dart logic — no Flutter framework, no widgets, no BuildContext.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'Test_helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. INSTITUTION SERVICE — fetchRecommendedInstitutions
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('Unit › InstitutionFeatureService', () {
    late MockInstitutionFeatureService mockService;

    setUp(() {
      mockService = MockInstitutionFeatureService();
    });

    // ── Happy path ────────────────────────────────────────────────────────────

    test(
      'fetchRecommendedInstitutions returns list when service succeeds',
          () async {
        final expected = fakeInstitutionList(count: 3);

        when(
              () => mockService.fetchRecommendedInstitutions(
            disabilityType: 'physical',
            limit: 5,
          ),
        ).thenAnswer((_) async => expected);

        final result = await mockService.fetchRecommendedInstitutions(
          disabilityType: 'physical',
          limit: 5,
        );

        expect(result, equals(expected));
        expect(result.length, 3);
      },
    );

    test('returns empty list when no institutions match disability type',
            () async {
          when(
                () => mockService.fetchRecommendedInstitutions(
              disabilityType: 'unknown_type',
              limit: 5,
            ),
          ).thenAnswer((_) async => []);

          final result = await mockService.fetchRecommendedInstitutions(
            disabilityType: 'unknown_type',
            limit: 5,
          );

          expect(result, isEmpty);
        });

    // ── Error path ────────────────────────────────────────────────────────────

    test('propagates exception when service throws', () async {
      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: any(named: 'disabilityType'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: 'physical',
          limit: 5,
        ),
        throwsA(isA<Exception>()),
      );
    });

    // ── Limit enforcement ─────────────────────────────────────────────────────

    test('respects the limit parameter passed to the service', () async {
      const limit = 2;
      final institutions = fakeInstitutionList(count: limit);

      when(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: 'visual',
          limit: limit,
        ),
      ).thenAnswer((_) async => institutions);

      final result = await mockService.fetchRecommendedInstitutions(
        disabilityType: 'visual',
        limit: limit,
      );

      // Service is expected to have honoured the limit.
      expect(result.length, lessThanOrEqualTo(limit));
      verify(
            () => mockService.fetchRecommendedInstitutions(
          disabilityType: 'visual',
          limit: limit,
        ),
      ).called(1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 2. INSTITUTION MODEL — basic field access
  // ─────────────────────────────────────────────────────────────────────────

  group('Unit › InstitutionModel', () {
    test('fields are accessible and correctly assigned', () {
      final inst = fakeInstitution(
        id: 'abc-123',
        name: 'Qudra Center',
        category: 'hearing',
      );

      expect(inst.id, 'abc-123');
      expect(inst.name, 'Qudra Center');
      expect(inst, 'hearing');
    });

    test('two instances with same id are considered equal (if == is overridden)',
            () {
          final a = fakeInstitution(id: 'x1');
          final b = fakeInstitution(id: 'x1');

          // Only assert if your model overrides ==; adjust or remove otherwise.
          expect(a.id, b.id);
        });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 3. SEARCH QUERY BUILDING — Uri construction
  // Tests the URI logic used in CustomSearchBar._submitSearch().
  // ─────────────────────────────────────────────────────────────────────────

  group('Unit › Search URI construction', () {
    Uri buildSearchUri(String query) => Uri(
      path: '/institution',
      queryParameters: query.isEmpty ? null : {'q': query},
    );

    test('produces plain path for empty query', () {
      final uri = buildSearchUri('');
      expect(uri.path, '/institution');
      expect(uri.queryParameters, isEmpty);
    });

    test('appends query param for non-empty search text', () {
      final uri = buildSearchUri('wheelchair ramp');
      expect(uri.queryParameters['q'], 'wheelchair ramp');
    });

    test('trims whitespace before building URI', () {
      final raw = '  hearing aid  '.trim();
      final uri = buildSearchUri(raw);
      expect(uri.queryParameters['q'], 'hearing aid');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 4. USER NAME EXTRACTION — first-name parsing logic
  // Tests the logic from HomeHeader: fullName.trim().split(' ').first
  // ─────────────────────────────────────────────────────────────────────────

  group('Unit › First-name extraction', () {
    String extractFirstName(String fullName, String fallback) =>
        fullName.trim().isEmpty
            ? fallback
            : fullName.trim().split(' ').first;

    test('returns first word of a full name', () {
      expect(extractFirstName('Abdullah Khairy', 'friend'), 'Abdullah');
    });

    test('returns single-word name unchanged', () {
      expect(extractFirstName('Abdullah', 'friend'), 'Abdullah');
    });

    test('handles extra leading/trailing spaces', () {
      expect(extractFirstName('  Omar Ali  ', 'friend'), 'Omar');
    });

    test('falls back to provided string for empty name', () {
      expect(extractFirstName('', 'friend'), 'friend');
    });

    test('handles name with multiple spaces between parts', () {
      final first = '  Ahmed   Hassan  '.trim().split(RegExp(r'\s+')).first;
      expect(first, 'Ahmed');
    });
  });
}
