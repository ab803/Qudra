import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_cubit.dart';
import 'package:qudra_0/core/Models/tips&rightsModel.dart';
import 'package:qudra_0/Feature/accessibility/repo/rights&tipsRepo.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock
// ─────────────────────────────────────────────────────────────────────────────
class MockRightstipsRepository extends Mock implements RightstipsRepository {}

// ─────────────────────────────────────────────────────────────────────────────
// Fixtures
// ─────────────────────────────────────────────────────────────────────────────
tipsRightsModel _model({int id = 1}) => tipsRightsModel.fromJson({
  'id': id,
  'title': 'Tip $id',
  'content': 'Content $id',
  'type': 'tip',
});

final tList = [_model(id: 1), _model(id: 2), _model(id: 3)];

void main() {
  late MockRightstipsRepository mockRepo;

  setUp(() {
    mockRepo = MockRightstipsRepository();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────────────────────────────
  test('initial state is RightstipsInitial', () {
    final cubit = RightstipsCubit(mockRepo);
    expect(cubit.state, isA<RightstipsInitial>());
    cubit.close();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // loadAll
  // ─────────────────────────────────────────────────────────────────────────
  group('RightstipsCubit.loadAll', () {
    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => tList);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'Loaded state carries the correct list',
      build: () {
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => tList);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<RightstipsLoading>(),
        predicate<RightstipsState>((s) =>
        s is RightstipsLoaded && s.tips.length == 3),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => mockRepo.fetchAll())
            .thenThrow(Exception('server down'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsError>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'Error state contains the exception message',
      build: () {
        when(() => mockRepo.fetchAll())
            .thenThrow(Exception('DB connection refused'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<RightstipsLoading>(),
        predicate<RightstipsState>((s) =>
        s is RightstipsError &&
            s.message.contains('DB connection refused')),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'emits Loaded with an empty list when repository returns nothing',
      build: () {
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => []);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.loadAll(),
      expect: () => [
        isA<RightstipsLoading>(),
        predicate<RightstipsState>(
                (s) => s is RightstipsLoaded && s.tips.isEmpty),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // create
  // ─────────────────────────────────────────────────────────────────────────
  group('RightstipsCubit.create', () {
    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, ActionSuccess, Loading, Loaded] on success',
      build: () {
        final m = _model();
        when(() => mockRepo.create(m)).thenAnswer((_) async => m);
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => [m]);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.create(_model()),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsActionSuccess>(),
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, Error] when create fails',
      build: () {
        when(() => mockRepo.create(any()))
            .thenThrow(Exception('unique constraint'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.create(_model()),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsError>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'calls fetchAll after a successful create',
      build: () {
        final m = _model();
        when(() => mockRepo.create(m)).thenAnswer((_) async => m);
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => [m]);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.create(_model()),
      verify: (_) {
        verify(() => mockRepo.fetchAll()).called(1);
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // update
  // ─────────────────────────────────────────────────────────────────────────
  group('RightstipsCubit.update', () {
    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, ActionSuccess, Loading, Loaded] on success',
      build: () {
        final m = _model();
        when(() => mockRepo.update(1, m)).thenAnswer((_) async => m);
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => tList);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.update(1, _model()),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsActionSuccess>(),
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, Error] when update fails',
      build: () {
        when(() => mockRepo.update(any(), any()))
            .thenThrow(Exception('row locked'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.update(1, _model()),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsError>(),
      ],
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // delete
  // ─────────────────────────────────────────────────────────────────────────
  group('RightstipsCubit.delete', () {
    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, ActionSuccess, Loading, Loaded] on success',
      build: () {
        when(() => mockRepo.delete(1)).thenAnswer((_) async {});
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => tList);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.delete(1),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsActionSuccess>(),
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'emits [Loading, Error] when delete fails',
      build: () {
        when(() => mockRepo.delete(any()))
            .thenThrow(Exception('FK violation'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.delete(1),
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsError>(),
      ],
    );

    blocTest<RightstipsCubit, RightstipsState>(
      'does not call fetchAll when delete fails',
      build: () {
        when(() => mockRepo.delete(any()))
            .thenThrow(Exception('FK violation'));
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) => cubit.delete(1),
      verify: (_) {
        verifyNever(() => mockRepo.fetchAll());
      },
    );
  });

  // ─────────────────────────────────────────────────────────────────────────
  // State transitions under rapid successive calls
  // ─────────────────────────────────────────────────────────────────────────
  group('RightstipsCubit – concurrent calls', () {
    blocTest<RightstipsCubit, RightstipsState>(
      'handles back-to-back loadAll calls without state corruption',
      build: () {
        when(() => mockRepo.fetchAll()).thenAnswer((_) async => tList);
        return RightstipsCubit(mockRepo);
      },
      act: (cubit) async {
        await cubit.loadAll();
        await cubit.loadAll();
      },
      expect: () => [
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
        isA<RightstipsLoading>(),
        isA<RightstipsLoaded>(),
      ],
    );
  });
}