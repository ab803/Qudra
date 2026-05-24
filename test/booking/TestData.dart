import 'package:qudra_0/Feature/booking/models/booking_model.dart';
import 'package:qudra_0/Feature/booking/models/booking_payment_model.dart';
import 'package:qudra_0/Feature/booking/models/user_booking_item_model.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/models/service_model.dart';


// ---------------------------------------------------------------------------
// BookingModel factory
// ---------------------------------------------------------------------------

BookingModel makeBooking({
  String id = 'booking-1',
  String userId = 'user-1',
  String institutionId = 'inst-1',
  String serviceId = 'service-1',
  String bookingStatus = 'confirmed',
  String paymentStatus = 'success',
  String paymentMethod = 'card',
  double amount = 150.0,
  String requestedTime = '10:00',
}) {
  return BookingModel(
    id: id,
    userId: userId,
    institutionId: institutionId,
    serviceId: serviceId,
    requestedDate: DateTime(2025, 6, 1),
    requestedTime: requestedTime,
    amount: amount,
    bookingStatus: bookingStatus,
    paymentMethod: paymentMethod,
    paymentStatus: paymentStatus,
  );
}

Map<String, dynamic> bookingJsonMap({
  String id = 'booking-1',
  String bookingStatus = 'confirmed',
  String paymentStatus = 'success',
  String paymentMethod = 'card',
  double amount = 150.0,
  String? notes,
  String? confirmedAt,
  String? cancelledAt,
}) =>
    {
      'id': id,
      'user_id': 'user-1',
      'institution_id': 'inst-1',
      'service_id': 'service-1',
      'requested_date': '2025-06-01',
      'requested_time': '10:00',
      'notes': notes,
      'amount': amount,
      'booking_status': bookingStatus,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paymob_order_id': null,
      'paymob_intention_id': null,
      'confirmed_at': confirmedAt,
      'cancelled_at': cancelledAt,
      'created_at': '2025-05-01T10:00:00.000Z',
      'updated_at': null,
    };

// ---------------------------------------------------------------------------
// BookingPaymentModel factory
// ---------------------------------------------------------------------------

BookingPaymentModel makePayment({
  String id = 'payment-1',
  String bookingId = 'booking-1',
  String paymentStatus = 'success',
}) {
  return BookingPaymentModel(
    id: id,
    bookingId: bookingId,
    paymentStatus: paymentStatus, provider: '', paymentMethod: '', amount: 0,
  );
}

Map<String, dynamic> paymentJsonMap({
  String id = 'payment-1',
  String bookingId = 'booking-1',
  String paymentStatus = 'success',
}) =>
    {
      'id': id,
      'booking_id': bookingId,
      'payment_status': paymentStatus,
      'created_at': '2025-05-01T10:00:00.000Z',
      'updated_at': null,
    };

// ---------------------------------------------------------------------------
// UserBookingItemModel factory
// ---------------------------------------------------------------------------

UserBookingItemModel makeUserBookingItem({
  String id = 'booking-1',
  String institutionId = 'inst-1',
  String institutionName = 'Test Institution',
  String serviceName = 'Test Service',
  String bookingStatus = 'confirmed',
  String paymentStatus = 'success',
  String paymentMethod = 'card',
  double amount = 150.0,
}) {
  return UserBookingItemModel(
    id: id,
    institutionId: institutionId,
    institutionName: institutionName,
    serviceName: serviceName,
    requestedDate: DateTime(2025, 6, 1),
    requestedTime: '10:00',
    amount: amount,
    bookingStatus: bookingStatus,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
  );
}

// ---------------------------------------------------------------------------
// InstitutionModel / InstitutionServiceModel stubs
// ---------------------------------------------------------------------------

InstitutionModel makeInstitution({
  String id = 'inst-1',
  String name = 'Test Institution',
}) {
  return InstitutionModel(id: id, name: name, email: '', institutionType: '', location: '');
}

InstitutionServiceModel makeService({
  String id = 'service-1',
  String name = 'Test Service',
  double price = 150.0,
}) {
  return InstitutionServiceModel(id: id, name: name, price: price, institutionId: '', category: '', supportedDisabilities: [], isFree: true, durationMinutes: 0, locationMode: '', bookingType: '', workingDays: [], isActive: true);
}

// ---------------------------------------------------------------------------
// Supabase-like response builder helpers
// ---------------------------------------------------------------------------

/// Simulates a confirmed booking session response (cash / confirmed inline).
Map<String, dynamic> confirmedSessionResponse({String bookingId = 'booking-1'}) =>
    {
      'success': true,
      'requires_redirect': false,
      'booking': bookingJsonMap(id: bookingId, bookingStatus: 'confirmed'),
      'payment': paymentJsonMap(bookingId: bookingId, paymentStatus: 'success'),
    };

/// Simulates a redirect (card / wallet) booking session response.
Map<String, dynamic> redirectSessionResponse({
  String bookingId = 'booking-1',
  String checkoutUrl = 'https://accept.paymob.com/pay/xyz',
  String paymentMethod = 'card',
}) =>
    {
      'success': true,
      'requires_redirect': true,
      'booking_id': bookingId,
      'checkout_url': checkoutUrl,
      'message': 'Redirect to Paymob checkout.',
    };

/// Simulates a failed booking session response.
Map<String, dynamic> failedSessionResponse({
  String error = 'Slot is already booked.',
}) =>
    {
      'success': false,
      'error': error,
    };