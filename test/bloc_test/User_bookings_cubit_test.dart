import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/booking/models/user_booking_item_model.dart';
import 'package:qudra_0/Feature/booking/viewmodel/user_bookings_cubit.dart';
import 'package:qudra_0/Feature/booking/viewmodel/user_bookings_state.dart';

import '../booking/Mock classes.dart';
import '../booking/TestData.dart';



void main() {
  group('UserBookingsCubit', () {
    late MockUserBookingsService service;

    setUp(() {
      registerFallbacks();
      service = MockUserBookingsService();
    });

    // -----------------------------------------------------------------------
    // Initial state
    // -----------------------------------------------------------------------
    test('initial state is UserBookingsInitial', () {
      final cubit = UserBookingsCubit(service);
      expect(cubit.state, isA<UserBookingsInitial>());
    });

    // -----------------------------------------------------------------------
    // loadCurrentUserBookings — success paths
    // -----------------------------------------------------------------------
    group('loadCurrentUserBookings – success', () {
      blocTest<UserBookingsCubit, UserBookingsState>(
        'emits [UserBookingsLoading, UserBookingsLoaded] with returned items',
        build: () {
          when(() => service.getCurrentUserBookings()).thenAnswer(
            (_) async => [
              makeUserBookingItem(id: 'b1', bookingStatus: 'confirmed'),
              makeUserBookingItem(id: 'b2', bookingStatus: 'failed'),
            ],
          );
          return UserBookingsCubit(service);
        },
        act: (c) => c.loadCurrentUserBookings(),
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>().having(
            (s) => s.bookings.length,
            'bookings.length',
            2,
          ),
        ],
      );

      blocTest<UserBookingsCubit, UserBookingsState>(
        'emits UserBookingsLoaded with empty list when user has no bookings',
        build: () {
          when(() => service.getCurrentUserBookings())
              .thenAnswer((_) async => []);
          return UserBookingsCubit(service);
        },
        act: (c) => c.loadCurrentUserBookings(),
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>().having(
            (s) => s.bookings,
            'bookings',
            isEmpty,
          ),
        ],
      );

      blocTest<UserBookingsCubit, UserBookingsState>(
        'loaded state preserves the correct booking fields',
        build: () {
          when(() => service.getCurrentUserBookings()).thenAnswer(
            (_) async => [
              makeUserBookingItem(
                id: 'booking-99',
                institutionName: 'Top Hospital',
                serviceName: 'Physio',
                bookingStatus: 'confirmed',
                paymentStatus: 'success',
                paymentMethod: 'wallet',
                amount: 300.0,
              ),
            ],
          );
          return UserBookingsCubit(service);
        },
        act: (c) => c.loadCurrentUserBookings(),
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>().having(
            (s) => s.bookings.first,
            'first booking',
            isA<UserBookingItemModel>()
                .having((b) => b.id, 'id', 'booking-99')
                .having((b) => b.institutionName, 'institutionName', 'Top Hospital')
                .having((b) => b.serviceName, 'serviceName', 'Physio')
                .having((b) => b.amount, 'amount', 300.0)
                .having((b) => b.paymentMethod, 'paymentMethod', 'wallet'),
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // loadCurrentUserBookings — error path
    // -----------------------------------------------------------------------
    group('loadCurrentUserBookings – error', () {
      blocTest<UserBookingsCubit, UserBookingsState>(
        'emits [UserBookingsLoading, UserBookingsError] when service throws',
        build: () {
          when(() => service.getCurrentUserBookings())
              .thenThrow(Exception('User is not logged in.'));
          return UserBookingsCubit(service);
        },
        act: (c) => c.loadCurrentUserBookings(),
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsError>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('not logged in'),
          ),
        ],
      );

      blocTest<UserBookingsCubit, UserBookingsState>(
        'emits UserBookingsError with the raw error message',
        build: () {
          when(() => service.getCurrentUserBookings())
              .thenThrow(Exception('Connection timeout'));
          return UserBookingsCubit(service);
        },
        act: (c) => c.loadCurrentUserBookings(),
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsError>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Connection timeout'),
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // Reload
    // -----------------------------------------------------------------------
    group('reload / refresh', () {
      blocTest<UserBookingsCubit, UserBookingsState>(
        'calling loadCurrentUserBookings twice emits Loading each time',
        build: () {
          when(() => service.getCurrentUserBookings())
              .thenAnswer((_) async => [makeUserBookingItem()]);
          return UserBookingsCubit(service);
        },
        act: (c) async {
          await c.loadCurrentUserBookings();
          await c.loadCurrentUserBookings();
        },
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>(),
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>(),
        ],
      );

      blocTest<UserBookingsCubit, UserBookingsState>(
        'second load reflects updated data from service',
        build: () {
          var callCount = 0;
          when(() => service.getCurrentUserBookings()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) return [makeUserBookingItem(id: 'b1')];
            return [
              makeUserBookingItem(id: 'b1'),
              makeUserBookingItem(id: 'b2'),
            ];
          });
          return UserBookingsCubit(service);
        },
        act: (c) async {
          await c.loadCurrentUserBookings();
          await c.loadCurrentUserBookings();
        },
        expect: () => [
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>()
              .having((s) => s.bookings.length, 'count first load', 1),
          isA<UserBookingsLoading>(),
          isA<UserBookingsLoaded>()
              .having((s) => s.bookings.length, 'count second load', 2),
        ],
      );
    });
  });
}