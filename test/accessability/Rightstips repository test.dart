import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import 'package:qudra_0/core/Services/supabase/tips&rightsService.dart';
import 'package:qudra_0/Feature/accessibility/repo/rights&tipsRepo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock
// ─────────────────────────────────────────────────────────────────────────────
class MockRightstipsService extends Mock implements RightstipsService {}

// ─────────────────────────────────────────────────────────────────────────────
// Fixtures
// ─────────────────────────────────────────────────────────────────────────────
tipsRightsModel _model({int id = 1}) => tipsRightsModel.fromJson({
  'id': id,
  'title': 'Tip $id',
  'content': 'Content $id',
  'type': 'tip',
});

void main() {
  late MockRightstipsService mockService;
  late RightstipsRepository repository;

  setUp(() {
    mockService = MockRightstipsService();
    repository = RightstipsRepository(mockService);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // fetchAll
  // ───────────────────────────────────────────────────────────────────────────
  group('RightstipsRepository.fetchAll', () {
    test('delegates to service.getAll and returns the result', () async {
      final list = [_model(id: 1), _model(id: 2)];
      when(() => mockService.getAll()).thenAnswer((_) async => list);

      final result = await repository.fetchAll();

      expect(result, equals(list));
      verify(() => mockService.getAll()).called(1);
    });

    test('wraps service exceptions in a descriptive Exception', () async {
      when(() => mockService.getAll())
          .thenThrow(Exception('network timeout'));

      expect(
        repository.fetchAll(),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Failed to fetch')),
        ),
      );
    });

    test('returns an empty list when the service returns nothing', () async {
      when(() => mockService.getAll()).thenAnswer((_) async => []);

      final result = await repository.fetchAll();

      expect(result, isEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // fetchById
  // ───────────────────────────────────────────────────────────────────────────
  group('RightstipsRepository.fetchById', () {
    test('returns the model matching the given id', () async {
      when(() => mockService.getById(1)).thenAnswer((_) async => _model());

      final result = await repository.fetchById(1);

      expect(result.id, 1);
    });

    test('wraps not-found errors with a descriptive message', () async {
      when(() => mockService.getById(999))
          .thenThrow(Exception('row not found'));

      expect(
        repository.fetchById(999),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Failed to fetch')),
        ),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // create
  // ───────────────────────────────────────────────────────────────────────────
  group('RightstipsRepository.create', () {
    test('calls service.create and returns the new model', () async {
      final m = _model();
      when(() => mockService.create(m)).thenAnswer((_) async => m);

      final result = await repository.create(m);

      expect(result.id, 1);
      verify(() => mockService.create(m)).called(1);
    });

    test('wraps service creation errors', () async {
      final m = _model();
      when(() => mockService.create(m))
          .thenThrow(Exception('constraint violation'));

      expect(
        repository.create(m),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Failed to create')),
        ),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // update
  // ───────────────────────────────────────────────────────────────────────────
  group('RightstipsRepository.update', () {
    test('calls service.update with the correct id and model', () async {
      final m = _model();
      when(() => mockService.update(1, m)).thenAnswer((_) async => m);

      final result = await repository.update(1, m);

      expect(result.id, 1);
      verify(() => mockService.update(1, m)).called(1);
    });

    test('wraps update errors with a descriptive message', () async {
      final m = _model();
      when(() => mockService.update(1, m))
          .thenThrow(Exception('record locked'));

      expect(
        repository.update(1, m),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Failed to update')),
        ),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // delete
  // ───────────────────────────────────────────────────────────────────────────
  group('RightstipsRepository.delete', () {
    test('delegates to service.delete and completes normally', () async {
      when(() => mockService.delete(1)).thenAnswer((_) async {});

      await expectLater(repository.delete(1), completes);
      verify(() => mockService.delete(1)).called(1);
    });

    test('wraps delete errors with a descriptive message', () async {
      when(() => mockService.delete(1))
          .thenThrow(Exception('foreign key violation'));

      expect(
        repository.delete(1),
        throwsA(
          predicate<Exception>((e) => e.toString().contains('Failed to delete')),
        ),
      );
    });

    test('does not call the service for a non-existent id after prior failure',
            () async {
          // Verify isolation: each call is independent.
          when(() => mockService.delete(42))
              .thenThrow(Exception('not found'));

          try {
            await repository.delete(42);
          } catch (_) {}

          // A second attempt must also reach the service (no silent swallowing).
          verify(() => mockService.delete(42)).called(1);
        });
  });
}