import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/booking/viewmodel/booking_cubit.dart';
import 'package:qudra_0/Feature/booking/viewmodel/booking_state.dart';

import '../booking/Mock classes.dart';
import '../booking/TestData.dart';


// ---------------------------------------------------------------------------
// Shared constants
// ---------------------------------------------------------------------------

const _serviceId = 's1';
const _institutionId = 'i1';
final _requestedDate = DateTime(2025, 6, 1);
const _requestedTime = '10:00';
const _bookingId = 'booking-1';

// ---------------------------------------------------------------------------
// Shared setup
// ---------------------------------------------------------------------------

MockBookingService _setup() {
  registerFallbacks();
  return MockBookingService();
}

BookingCubit _cubit(MockBookingService svc) => BookingCubit(svc);

// ---------------------------------------------------------------------------
// createBookingSession
// ---------------------------------------------------------------------------

void main() {
  group('BookingCubit', () {
    // -----------------------------------------------------------------------
    // createBookingSession — card path (requires_redirect: true)
    // -----------------------------------------------------------------------
    group('createBookingSession – card redirect', () {
      blocTest<BookingCubit, BookingState>(
        'emits [BookingLoading, BookingSessionCreated] when redirect is required',
        build: () {
          final svc = _setup();
          when(() => svc.createBookingSession(
            serviceId: any(named: 'serviceId'),
            institutionId: any(named: 'institutionId'),
            requestedDate: any(named: 'requestedDate'),
            requestedTime: any(named: 'requestedTime'),
            paymentMethod: any(named: 'paymentMethod'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => redirectSessionResponse());
          return _cubit(svc);
        },
        act: (c) => c.createBookingSession(
          serviceId: _serviceId,
          institutionId: _institutionId,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          paymentMethod: 'card',
        ),
        expect: () => [
          isA<BookingLoading>(),
          isA<BookingSessionCreated>()
              .having((s) => s.bookingId, 'bookingId', _bookingId)
              .having((s) => s.paymentMethod, 'paymentMethod', 'card')
              .having(
                (s) => s.checkoutUrl,
            'checkoutUrl',
            contains('paymob'),
          ),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'BookingSessionCreated carries the checkout URL from the response',
        build: () {
          final svc = _setup();
          when(() => svc.createBookingSession(
            serviceId: any(named: 'serviceId'),
            institutionId: any(named: 'institutionId'),
            requestedDate: any(named: 'requestedDate'),
            requestedTime: any(named: 'requestedTime'),
            paymentMethod: any(named: 'paymentMethod'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => redirectSessionResponse(
            checkoutUrl: 'https://accept.paymob.com/pay/abc123',
          ));
          return _cubit(svc);
        },
        act: (c) => c.createBookingSession(
          serviceId: _serviceId,
          institutionId: _institutionId,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          paymentMethod: 'card',
        ),
        expect: () => [
          isA<BookingLoading>(),
          isA<BookingSessionCreated>().having(
                (s) => s.checkoutUrl,
            'checkoutUrl',
            'https://accept.paymob.com/pay/abc123',
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // createBookingSession — cash / inline-confirmed path
    // -----------------------------------------------------------------------
    group('createBookingSession – cash inline confirm', () {
      blocTest<BookingCubit, BookingState>(
        'emits [BookingLoading, BookingConfirmed] for cash when booking is confirmed inline',
        build: () {
          final svc = _setup();
          when(() => svc.createBookingSession(
            serviceId: any(named: 'serviceId'),
            institutionId: any(named: 'institutionId'),
            requestedDate: any(named: 'requestedDate'),
            requestedTime: any(named: 'requestedTime'),
            paymentMethod: any(named: 'paymentMethod'),
            notes: any(named: 'notes'),
          )).thenAnswer(
                (_) async => confirmedSessionResponse(),
          );
          return _cubit(svc);
        },
        act: (c) => c.createBookingSession(
          serviceId: _serviceId,
          institutionId: _institutionId,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          paymentMethod: 'cash_at_institution',
        ),
        expect: () => [
          isA<BookingLoading>(),
          isA<BookingConfirmed>().having(
                (s) => s.booking.id,
            'bookingId',
            _bookingId,
          ),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingFailed when inline response has non-confirmed status',
        build: () {
          final svc = _setup();
          when(() => svc.createBookingSession(
            serviceId: any(named: 'serviceId'),
            institutionId: any(named: 'institutionId'),
            requestedDate: any(named: 'requestedDate'),
            requestedTime: any(named: 'requestedTime'),
            paymentMethod: any(named: 'paymentMethod'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async {
            return {
              'success': true,
              'requires_redirect': false,
              'booking':
              bookingJsonMap(bookingStatus: 'pending_payment'),
              'payment':
              paymentJsonMap(paymentStatus: 'pending'),
            };
          });
          return _cubit(svc);
        },
        act: (c) => c.createBookingSession(
          serviceId: _serviceId,
          institutionId: _institutionId,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          paymentMethod: 'cash_at_institution',
        ),
        expect: () => [
          isA<BookingLoading>(),
          isA<BookingFailed>().having(
                (s) => s.errorMessage,
            'errorMessage',
            contains('not confirmed'),
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // createBookingSession — service error path
    // -----------------------------------------------------------------------
    group('createBookingSession – error path', () {
      blocTest<BookingCubit, BookingState>(
        'emits [BookingLoading, BookingError] when service throws',
        build: () {
          final svc = _setup();
          when(() => svc.createBookingSession(
            serviceId: any(named: 'serviceId'),
            institutionId: any(named: 'institutionId'),
            requestedDate: any(named: 'requestedDate'),
            requestedTime: any(named: 'requestedTime'),
            paymentMethod: any(named: 'paymentMethod'),
            notes: any(named: 'notes'),
          )).thenThrow(Exception('Network error'));
          return _cubit(svc);
        },
        act: (c) => c.createBookingSession(
          serviceId: _serviceId,
          institutionId: _institutionId,
          requestedDate: _requestedDate,
          requestedTime: _requestedTime,
          paymentMethod: 'card',
        ),
        expect: () => [
          isA<BookingLoading>(),
          isA<BookingError>().having(
                (s) => s.errorMessage,
            'errorMessage',
            contains('Network error'),
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // waitForFinalBookingStatus
    // -----------------------------------------------------------------------
    group('waitForFinalBookingStatus', () {
      blocTest<BookingCubit, BookingState>(
        'emits [BookingProcessing, BookingConfirmed] when booking is confirmed on first poll',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking': makeBooking(bookingStatus: 'confirmed'),
              'payment': makePayment(paymentStatus: 'success'),
            },
          );
          return _cubit(svc);
        },
        act: (c) => c.waitForFinalBookingStatus(_bookingId),
        expect: () => [
          isA<BookingProcessing>().having(
                (s) => s.bookingId,
            'bookingId',
            _bookingId,
          ),
          isA<BookingConfirmed>().having(
                (s) => s.booking.bookingStatus,
            'bookingStatus',
            'confirmed',
          ),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingFailed when booking status is failed',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking': makeBooking(
                bookingStatus: 'failed',
                paymentStatus: 'failed',
              ),
              'payment': makePayment(paymentStatus: 'failed'),
            },
          );
          return _cubit(svc);
        },
        act: (c) => c.waitForFinalBookingStatus(_bookingId),
        expect: () => [
          isA<BookingProcessing>(),
          isA<BookingFailed>().having(
                (s) => s.errorMessage,
            'errorMessage',
            contains('not completed'),
          ),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingFailed when booking status is cancelled',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking': makeBooking(bookingStatus: 'cancelled'),
              'payment': makePayment(paymentStatus: 'failed'),
            },
          );
          return _cubit(svc);
        },
        act: (c) => c.waitForFinalBookingStatus(_bookingId),
        expect: () => [
          isA<BookingProcessing>(),
          isA<BookingFailed>(),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingPendingResult after exhausting all retries',
        build: () {
          final svc = _setup();
          // Always return pending — never confirms.
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking':
              makeBooking(bookingStatus: 'pending_payment', paymentStatus: 'pending'),
              'payment': makePayment(paymentStatus: 'pending'),
            },
          );
          return _cubit(svc);
        },
        act: (c) => c.waitForFinalBookingStatus(_bookingId),
        // Polling is fast in tests because _statusCheckDelay is awaited;
        // use a long timeout to be safe.

        expect: () => [
          isA<BookingProcessing>(),
          // After max retries, falls through to BookingPendingResult.
          isA<BookingPendingResult>().having(
                (s) => s.bookingId,
            'bookingId',
            _bookingId,
          ),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingError if all snapshot calls throw',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(any()))
              .thenThrow(Exception('timeout'));
          return _cubit(svc);
        },
        act: (c) => c.waitForFinalBookingStatus(_bookingId),

        expect: () => [
          isA<BookingProcessing>(),
          isA<BookingError>().having(
                (s) => s.errorMessage,
            'errorMessage',
            contains('verify your payment'),
          ),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // resolveCheckoutReturnAfterExternalCheckout
    // -----------------------------------------------------------------------
    group('resolveCheckoutReturnAfterExternalCheckout', () {
      blocTest<BookingCubit, BookingState>(
        'emits BookingConfirmed when first snapshot is already confirmed',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking': makeBooking(bookingStatus: 'confirmed'),
              'payment': makePayment(paymentStatus: 'success'),
            },
          );
          return _cubit(svc);
        },
        act: (c) =>
            c.resolveCheckoutReturnAfterExternalCheckout(_bookingId),
        expect: () => [
          isA<BookingConfirmed>(),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'emits BookingFailed immediately when first snapshot is already failed',
        build: () {
          final svc = _setup();
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking': makeBooking(bookingStatus: 'failed'),
              'payment': makePayment(paymentStatus: 'failed'),
            },
          );
          return _cubit(svc);
        },
        act: (c) =>
            c.resolveCheckoutReturnAfterExternalCheckout(_bookingId),
        expect: () => [
          isA<BookingFailed>(),
        ],
      );

      blocTest<BookingCubit, BookingState>(
        'force-fails and emits BookingFailed when both snapshots are still pending',
        build: () {
          final svc = _setup();
          // Both snapshot calls return pending.
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer(
                (_) async => {
              'booking':
              makeBooking(bookingStatus: 'pending_payment', paymentStatus: 'pending'),
              'payment': makePayment(paymentStatus: 'pending'),
            },
          );
          when(() => svc.forceFailPendingBooking(_bookingId))
              .thenAnswer((_) async {});
          return _cubit(svc);
        },
        act: (c) =>
            c.resolveCheckoutReturnAfterExternalCheckout(_bookingId),

        expect: () => [
          isA<BookingFailed>(),
        ],
        verify: (c) {
          verify(() => c.resolveCheckoutReturnAfterExternalCheckout(_bookingId))
              .called(1);
        },
      );

      blocTest<BookingCubit, BookingState>(
        'falls back to waitForFinalBookingStatus when snapshot throws',
        build: () {
          final svc = _setup();
          var callCount = 0;
          when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) throw Exception('network issue');
            // Subsequent calls during polling return confirmed.
            return {
              'booking': makeBooking(bookingStatus: 'confirmed'),
              'payment': makePayment(paymentStatus: 'success'),
            };
          });
          return _cubit(svc);
        },
        act: (c) =>
            c.resolveCheckoutReturnAfterExternalCheckout(_bookingId),
        expect: () => [
          isA<BookingProcessing>(),
          isA<BookingConfirmed>(),
        ],
      );
    });

    // -----------------------------------------------------------------------
    // Token cancellation — stale polling does not overwrite newer state
    // -----------------------------------------------------------------------
    group('token cancellation', () {
      test(
          'starting a second waitForFinalBookingStatus cancels the first poll',
              () async {
            final svc = _setup();
            var callCount = 0;

            when(() => svc.getBookingSnapshot(_bookingId)).thenAnswer((_) async {
              callCount++;
              // First poll takes a long time (simulated via delay).
              if (callCount == 1) {
                await Future<void>.delayed(const Duration(seconds: 5));
              }
              return {
                'booking': makeBooking(bookingStatus: 'confirmed'),
                'payment': makePayment(paymentStatus: 'success'),
              };
            });

            final cubit = _cubit(svc);
            final states = <BookingState>[];
            cubit.stream.listen(states.add);

            // Start first poll — it will be delayed.
            final firstPoll = cubit.waitForFinalBookingStatus(_bookingId);

            // Immediately start a second poll that supersedes the first.
            final secondPoll = cubit.waitForFinalBookingStatus(_bookingId);

            await secondPoll;
            // Cancel the first in the background.
            firstPoll.ignore();

            // The second poll should have resolved with BookingConfirmed.
            expect(
              states,
              contains(isA<BookingConfirmed>()),
            );
          });
    });
  });
}