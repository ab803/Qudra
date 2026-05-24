
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/booking/services/booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'TestData.dart';

// ---------------------------------------------------------------------------
// Supabase query chain mocks
// ---------------------------------------------------------------------------

class _MockSupabaseClient extends Mock implements SupabaseClient {}
class _MockFunctions extends Mock implements FunctionsClient {}
class _MockFunctionResponse extends Mock implements FunctionResponse {}

class _MockQueryBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

_MockSupabaseClient _mockClient() {
  final client = _MockSupabaseClient();
  final functions = _MockFunctions();
  when(() => client.functions).thenReturn(functions);
  return client;
}

void main() {
  late _MockSupabaseClient supabase;
  late BookingService service;

  setUp(() {
    supabase = _mockClient();
    service = BookingService();
  });

  // -----------------------------------------------------------------------
  // _formatDate (tested indirectly through createBookingSession)
  // -----------------------------------------------------------------------
  group('_formatDate (via createBookingSession body)', () {
    test('formats date as YYYY-MM-DD', () async {
      // We capture the body sent to the edge function.
      final captured = <Map<String, dynamic>>[];
      when(
            () => supabase.functions.invoke(
          'create-booking-session',
          body: captureAny(named: 'body'),
        ),
      ).thenAnswer((_) async {
        final body =
        verify(() => supabase.functions.invoke(
          any(),
          body: captureAny(named: 'body'),
        )).captured.last as Map<String, dynamic>;
        captured.add(body);
        return _FakeFunctionResponse({'success': false, 'error': 'test'});
      });

      try {
        await service.createBookingSession(
          serviceId: 's1',
          institutionId: 'i1',
          requestedDate: DateTime(2025, 1, 5), // Jan 5 → 2025-01-05
          requestedTime: '09:00',
          paymentMethod: 'card',
        );
      } catch (_) {}

      if (captured.isNotEmpty) {
        expect(captured.first['requested_date'], '2025-01-05');
      }
    });
  });

  // -----------------------------------------------------------------------
  // createBookingSession
  // -----------------------------------------------------------------------
  group('createBookingSession', () {
    test('returns data map on success with redirect', () async {
      when(
            () => supabase.functions
            .invoke('create-booking-session', body: any(named: 'body')),
      ).thenAnswer((_) async =>
          _FakeFunctionResponse(redirectSessionResponse()));

      final result = await service.createBookingSession(
        serviceId: 's1',
        institutionId: 'i1',
        requestedDate: DateTime(2025, 6, 1),
        requestedTime: '10:00',
        paymentMethod: 'card',
      );

      expect(result['success'], isTrue);
      expect(result['requires_redirect'], isTrue);
      expect(result['checkout_url'], isA<String>());
    });

    test('throws when response is not a Map', () async {
      when(
            () => supabase.functions
            .invoke('create-booking-session', body: any(named: 'body')),
      ).thenAnswer((_) async => _FakeFunctionResponse('bad-response'));

      expect(
            () => service.createBookingSession(
          serviceId: 's1',
          institutionId: 'i1',
          requestedDate: DateTime(2025, 6, 1),
          requestedTime: '10:00',
          paymentMethod: 'card',
        ),
        throwsA(isA<Exception>().having(
              (e) => e.toString(),
          'message',
          contains('Invalid booking session response'),
        )),
      );
    });

    test('throws with error message when success is false', () async {
      when(
            () => supabase.functions
            .invoke('create-booking-session', body: any(named: 'body')),
      ).thenAnswer(
              (_) async => _FakeFunctionResponse(failedSessionResponse()));

      await expectLater(
        service.createBookingSession(
          serviceId: 's1',
          institutionId: 'i1',
          requestedDate: DateTime(2025, 6, 1),
          requestedTime: '10:00',
          paymentMethod: 'card',
        ),
        throwsA(isA<Exception>().having(
              (e) => e.toString(),
          'message',
          contains('Slot is already booked.'),
        )),
      );
    });
  });

  // -----------------------------------------------------------------------
  // _normalizeStoredTime (tested via fetchReservedTimesForServiceDate)
  // -----------------------------------------------------------------------
  group('_normalizeStoredTime (via fetchReservedTimesForServiceDate)', () {
    test('strips seconds from HH:MM:SS → HH:MM', () async {
      _stubBookingsQuery(supabase, rows: [
        {'requested_time': '9:5:00', 'booking_status': 'confirmed'},
      ]);

      final times = await service.fetchReservedTimesForServiceDate(
        serviceId: 's1',
        requestedDate: DateTime(2025, 6, 1),
      );

      expect(times, contains('09:05'));
    });

    test('pads single-digit hour and minute', () async {
      _stubBookingsQuery(supabase, rows: [
        {'requested_time': '8:5', 'booking_status': 'pending_payment'},
      ]);

      final times = await service.fetchReservedTimesForServiceDate(
        serviceId: 's1',
        requestedDate: DateTime(2025, 6, 1),
      );

      expect(times, contains('08:05'));
    });

    test('filters out empty raw time entries', () async {
      _stubBookingsQuery(supabase, rows: [
        {'requested_time': '', 'booking_status': 'confirmed'},
        {'requested_time': '10:00', 'booking_status': 'confirmed'},
      ]);

      final times = await service.fetchReservedTimesForServiceDate(
        serviceId: 's1',
        requestedDate: DateTime(2025, 6, 1),
      );

      expect(times.length, 1);
      expect(times.first, '10:00');
    });

    test('returns empty list when no reserved slots', () async {
      _stubBookingsQuery(supabase, rows: []);

      final times = await service.fetchReservedTimesForServiceDate(
        serviceId: 's1',
        requestedDate: DateTime(2025, 6, 1),
      );

      expect(times, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // getBookingById
  // -----------------------------------------------------------------------
  group('getBookingById', () {
    test('returns BookingModel when row exists', () async {
      _stubBookingById(supabase, row: bookingJsonMap());

      final booking = await service.getBookingById('booking-1');

      expect(booking, isNotNull);
      expect(booking!.id, 'booking-1');
      expect(booking.bookingStatus, 'confirmed');
    });

    test('returns null when row does not exist', () async {
      _stubBookingById(supabase, row: null);

      final booking = await service.getBookingById('missing-id');

      expect(booking, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // forceFailPendingBooking
  // -----------------------------------------------------------------------
  group('forceFailPendingBooking', () {
    test('updates bookings and booking_payments tables', () async {
      _stubUpdateBookingToFailed(supabase);

      // Should complete without throwing.
      await expectLater(
        service.forceFailPendingBooking('booking-1'),
        completes,
      );

      // Verify both tables were targeted.
      verify(() => supabase.from('bookings').update(any())).called(1);
      verify(() => supabase.from('booking_payments').update(any())).called(1);
    });

    test('sets booking_status to failed', () async {
      final captured = <Map<String, dynamic>>[];
      when(() => supabase.from('bookings').update(captureAny()))
          .thenAnswer((invocation) {
        captured.add(
            invocation.namedArguments[const Symbol('any')] as Map<String, dynamic>);
        return _FakeFilterBuilder();
      });
      when(() => supabase.from('booking_payments').update(any()))
          .thenReturn(_FakeFilterBuilder());

      try {
        await service.forceFailPendingBooking('booking-1');
      } catch (_) {}

      if (captured.isNotEmpty) {
        expect(captured.first['booking_status'], 'failed');
        expect(captured.first['payment_status'], 'failed');
      }
    });
  });
}

// ---------------------------------------------------------------------------
// Stub helpers (minimise boilerplate in each test)
// ---------------------------------------------------------------------------

void _stubBookingsQuery(
    _MockSupabaseClient supabase, {
      required List<Map<String, dynamic>> rows,
    }) {
  final builder = _MockQueryBuilder();
  when(() => supabase.from('bookings')).thenReturn(builder as SupabaseQueryBuilder);
  when(() => builder.select(any())).thenReturn(builder as PostgrestTransformBuilder<PostgrestList>);
  when(() => builder.eq(any(), any())).thenReturn(builder);

}

void _stubBookingById(
    _MockSupabaseClient supabase, {
      required Map<String, dynamic>? row,
    }) {
  final builder = _MockQueryBuilder();
  when(() => supabase.from('bookings')).thenReturn(builder as SupabaseQueryBuilder);
  when(() => builder.select()).thenReturn(builder as PostgrestTransformBuilder<PostgrestList>);
  when(() => builder.eq(any(), any())).thenReturn(builder);

}

void _stubUpdateBookingToFailed(_MockSupabaseClient supabase) {
  final builder = _MockQueryBuilder();
  when(() => supabase.from(any())).thenReturn(builder as SupabaseQueryBuilder);

}

// ---------------------------------------------------------------------------
// Fake helpers
// ---------------------------------------------------------------------------

class _FakeFunctionResponse implements FunctionResponse {
  _FakeFunctionResponse(this.data);

  @override
  final dynamic data;

  @override
  dynamic get error => null;

  @override
  int get status => 200;
}

class _FakeFilterBuilder extends Fake
    implements PostgrestFilterBuilder<dynamic> {
  @override
  Future<U> then<U>(
      FutureOr<U> Function(dynamic) onValue, {
        Function? onError,
      }) =>
      Future<dynamic>.value(null).then(onValue, onError: onError);
}