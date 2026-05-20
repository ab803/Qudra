import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';
import '../models/booking_payment_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<Map<String, dynamic>> createBookingSession({
    required String serviceId,
    required String institutionId,
    required DateTime requestedDate,
    required String requestedTime,
    required String paymentMethod,
    String? notes,
  }) async {
    final response = await _supabase.functions.invoke(
      'create-booking-session',
      body: {
        'service_id': serviceId,
        'institution_id': institutionId,
        'requested_date': _formatDate(requestedDate),
        'requested_time': requestedTime,
        'payment_method': paymentMethod,
        'notes': notes,
      },
    );

    if (response.data is! Map) {
      throw Exception('Invalid booking session response');
    }

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true) {
      throw Exception(data['error'] ?? 'Failed to create booking session');
    }

    return data;
  }

  // This method loads all already reserved slot times for a specific service and day.
  Future<List<String>> fetchReservedTimesForServiceDate({
    required String serviceId,
    required DateTime requestedDate,
  }) async {
    final result = await _supabase
        .from('bookings')
        .select('requested_time, booking_status')
        .eq('service_id', serviceId)
        .eq('requested_date', _formatDate(requestedDate))
        .inFilter('booking_status', ['pending_payment', 'confirmed']);

    return List<Map<String, dynamic>>.from(result).map((row) {
      final rawTime = row['requested_time']?.toString() ?? '';
      return _normalizeStoredTime(rawTime);
    }).where((time) => time.isNotEmpty).toList();
  }

  // This helper normalizes database time values into HH:mm format.
  String _normalizeStoredTime(String rawTime) {
    if (rawTime.trim().isEmpty) return '';
    final parts = rawTime.split(':');
    if (parts.length < 2) return rawTime;
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    final result = await _supabase
        .from('bookings')
        .select()
        .eq('id', bookingId)
        .maybeSingle();

    if (result == null) return null;

    return BookingModel.fromJson(Map<String, dynamic>.from(result));
  }

  Future<BookingPaymentModel?> getPaymentByBookingId(String bookingId) async {
    final result = await _supabase
        .from('booking_payments')
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (result == null) return null;

    return BookingPaymentModel.fromJson(
      Map<String, dynamic>.from(result),
    );
  }

  Future<Map<String, dynamic>> getBookingSnapshot(String bookingId) async {
    final booking = await getBookingById(bookingId);
    final payment = await getPaymentByBookingId(bookingId);

    return {
      'booking': booking,
      'payment': payment,
    };
  }

  /// ✅ الحل الحاسم
  /// أي Booking فضلت pending تتحول Failed في الداتابيز
  Future<void> forceFailPendingBooking(String bookingId) async {
    final now = DateTime.now().toIso8601String();

    await _supabase.from('bookings').update({
      'booking_status': 'failed',
      'payment_status': 'failed',
      'cancelled_at': now,
      'updated_at': now,
    }).eq('id', bookingId);

    await _supabase.from('booking_payments').update({
      'payment_status': 'failed',
      'updated_at': now,
    }).eq('booking_id', bookingId);
  }
}