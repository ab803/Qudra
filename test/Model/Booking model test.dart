import 'package:flutter_test/flutter_test.dart';
import 'package:qudra_0/Feature/booking/models/booking_model.dart';

import '../booking/TestData.dart';


void main() {
  group('BookingModel', () {
    // -----------------------------------------------------------------------
    // fromJson
    // -----------------------------------------------------------------------
    group('fromJson', () {
      test('maps every required field correctly', () {
        final model = BookingModel.fromJson(bookingJsonMap());

        expect(model.id, 'booking-1');
        expect(model.userId, 'user-1');
        expect(model.institutionId, 'inst-1');
        expect(model.serviceId, 'service-1');
        expect(model.requestedDate, DateTime(2025, 6, 1));
        expect(model.requestedTime, '10:00');
        expect(model.amount, 150.0);
        expect(model.bookingStatus, 'confirmed');
        expect(model.paymentMethod, 'card');
        expect(model.paymentStatus, 'success');
      });

      test('parses amount from int JSON value', () {
        final json = bookingJsonMap()..['amount'] = 200; // int, not double
        final model = BookingModel.fromJson(json);
        expect(model.amount, 200.0);
        expect(model.amount, isA<double>());
      });

      test('sets nullable fields to null when absent', () {
        final model = BookingModel.fromJson(bookingJsonMap());

        expect(model.notes, isNull);
        expect(model.paymobOrderId, isNull);
        expect(model.paymobIntentionId, isNull);
        expect(model.confirmedAt, isNull);
        expect(model.cancelledAt, isNull);
      });

      test('parses confirmedAt when present', () {
        final json = bookingJsonMap(confirmedAt: '2025-06-01T11:00:00.000Z');
        final model = BookingModel.fromJson(json);

        expect(model.confirmedAt, isNotNull);
        expect(model.confirmedAt!.year, 2025);
        expect(model.confirmedAt!.month, 6);
      });

      test('parses cancelledAt when present', () {
        final json = bookingJsonMap(cancelledAt: '2025-06-02T09:00:00.000Z');
        final model = BookingModel.fromJson(json);

        expect(model.cancelledAt, isNotNull);
        expect(model.cancelledAt!.day, 2);
      });

      test('parses createdAt when present', () {
        final model = BookingModel.fromJson(bookingJsonMap());
        expect(model.createdAt, isNotNull);
        expect(model.createdAt!.year, 2025);
      });

      test('handles malformed confirmedAt gracefully (returns null)', () {
        final json = bookingJsonMap()..['confirmed_at'] = 'not-a-date';
        final model = BookingModel.fromJson(json);
        // DateTime.tryParse returns null for invalid strings.
        expect(model.confirmedAt, isNull);
      });

      test('preserves notes when provided', () {
        final json = bookingJsonMap(notes: 'Please call ahead.');
        final model = BookingModel.fromJson(json);
        expect(model.notes, 'Please call ahead.');
      });

      test('parses wallet payment method', () {
        final json = bookingJsonMap(paymentMethod: 'wallet');
        final model = BookingModel.fromJson(json);
        expect(model.paymentMethod, 'wallet');
      });

      test('parses cash_at_institution payment method', () {
        final json = bookingJsonMap(paymentMethod: 'cash_at_institution');
        final model = BookingModel.fromJson(json);
        expect(model.paymentMethod, 'cash_at_institution');
      });
    });

    // -----------------------------------------------------------------------
    // toJson
    // -----------------------------------------------------------------------
    group('toJson', () {
      test('serializes all non-null fields', () {
        final model = makeBooking();
        final json = model.toJson();

        expect(json['id'], 'booking-1');
        expect(json['user_id'], 'user-1');
        expect(json['institution_id'], 'inst-1');
        expect(json['service_id'], 'service-1');
        expect(json['booking_status'], 'confirmed');
        expect(json['payment_method'], 'card');
        expect(json['payment_status'], 'success');
        expect(json['amount'], 150.0);
      });

      test('requested_date is formatted as yyyy-MM-dd (no time component)', () {
        final model = makeBooking();
        final json = model.toJson();
        final date = json['requested_date'] as String;

        expect(date, '2025-06-01');
        expect(date.contains('T'), isFalse);
      });

      test('nullable fields serialize as null when not set', () {
        final model = makeBooking();
        final json = model.toJson();

        expect(json['notes'], isNull);
        expect(json['paymob_order_id'], isNull);
        expect(json['paymob_intention_id'], isNull);
        expect(json['confirmed_at'], isNull);
        expect(json['cancelled_at'], isNull);
      });

      test('confirmed_at serializes as ISO8601 string when set', () {
        final confirmedAt = DateTime(2025, 6, 1, 11);
        final model = makeBooking().copyWith(confirmedAt: confirmedAt);
        final json = model.toJson();

        expect(json['confirmed_at'], isA<String>());
        expect(json['confirmed_at'], contains('2025-06-01'));
      });
    });

    // -----------------------------------------------------------------------
    // copyWith
    // -----------------------------------------------------------------------
    group('copyWith', () {
      test('returns identical model when no arguments passed', () {
        final original = makeBooking();
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.bookingStatus, original.bookingStatus);
        expect(copy.amount, original.amount);
      });

      test('overrides only the supplied field', () {
        final original = makeBooking(bookingStatus: 'confirmed');
        final copy = original.copyWith(bookingStatus: 'failed');

        expect(copy.bookingStatus, 'failed');
        expect(copy.id, original.id);
        expect(copy.paymentStatus, original.paymentStatus);
      });

      test('can nullify a nullable field via explicit null (notes)', () {
        final original =
        makeBooking().copyWith(notes: 'Some note');
        final cleared = original.copyWith(notes: null);

        // copyWith with null keeps the old value due to ?? fallback —
        // this test documents the current behaviour.
        expect(cleared.notes, isNull);
      });

      test('can update multiple fields at once', () {
        final original = makeBooking();
        final copy = original.copyWith(
          bookingStatus: 'cancelled',
          paymentStatus: 'failed',
          amount: 0.0,
        );

        expect(copy.bookingStatus, 'cancelled');
        expect(copy.paymentStatus, 'failed');
        expect(copy.amount, 0.0);
        expect(copy.id, original.id);
      });
    });

    // -----------------------------------------------------------------------
    // fromJson → toJson round-trip
    // -----------------------------------------------------------------------
    group('round-trip', () {
      test('fromJson → toJson preserves key values', () {
        final original = BookingModel.fromJson(bookingJsonMap());
        final roundTripped = BookingModel.fromJson(original.toJson());

        expect(roundTripped.id, original.id);
        expect(roundTripped.bookingStatus, original.bookingStatus);
        expect(roundTripped.amount, original.amount);
        expect(roundTripped.requestedDate.year, original.requestedDate.year);
      });
    });
  });
}