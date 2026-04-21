import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_booking_item_model.dart';

// This service loads all bookings created by the currently signed-in user.
class UserBookingsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // This method returns all bookings created by the current user with service and institution names.
  Future<List<UserBookingItemModel>> getCurrentUserBookings() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final bookingRows = await _supabase
        .from('bookings')
        .select(
      'id, institution_id, service_id, requested_date, requested_time, amount, booking_status, payment_status, payment_method, created_at, notes',
    )
        .eq('user_id', currentUser.id)
        .order('created_at', ascending: false);

    if (bookingRows.isEmpty) return [];

    final bookingList = List<Map<String, dynamic>>.from(bookingRows);

    final serviceIds = bookingList
        .map((row) => row['service_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    final institutionIds = bookingList
        .map((row) => row['institution_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    // This block loads the related services names used in the user bookings list.
    final serviceRows = serviceIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
      await _supabase
          .from('services')
          .select('id, name')
          .inFilter('id', serviceIds),
    );

    // This block loads the related institution names used in the user bookings list.
    final institutionRows = institutionIds.isEmpty
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
      await _supabase
          .from('institutions')
          .select('id, name')
          .inFilter('id', institutionIds),
    );

    final serviceNameById = <String, String>{
      for (final row in serviceRows)
        row['id'].toString(): row['name'].toString(),
    };

    final institutionNameById = <String, String>{
      for (final row in institutionRows)
        row['id'].toString(): row['name'].toString(),
    };

    // This block maps raw booking rows into UI-friendly booking list items.
    return bookingList.map((row) {
      final requestedDate = DateTime.parse(row['requested_date'].toString());

      return UserBookingItemModel(
        id: row['id'].toString(),
        institutionId: row['institution_id'].toString(),
        institutionName:
        institutionNameById[row['institution_id'].toString()] ??
            'Unknown Institution',
        serviceName:
        serviceNameById[row['service_id'].toString()] ??
            'Unknown Service',
        requestedDate: requestedDate,
        requestedTime: row['requested_time'].toString(),
        amount: (row['amount'] as num).toDouble(),
        bookingStatus: row['booking_status'].toString(),
        paymentStatus: row['payment_status'].toString(),
        paymentMethod: row['payment_method'].toString(),
        createdAt: row['created_at'] != null
            ? DateTime.tryParse(row['created_at'].toString())
            : null,
        notes: row['notes']?.toString(),
      );
    }).toList();
  }
}