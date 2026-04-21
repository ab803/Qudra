// This model represents a service booking created by a user.
class BookingModel {
  final String id;
  final String userId;
  final String institutionId;
  final String serviceId;
  final DateTime requestedDate;
  final String requestedTime;
  final String? notes;
  final double amount;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymobOrderId;
  final String? paymobIntentionId;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.institutionId,
    required this.serviceId,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
    required this.amount,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymobOrderId,
    this.paymobIntentionId,
    this.confirmedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  // This factory creates a booking model from a Supabase row.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      institutionId: json['institution_id'] as String,
      serviceId: json['service_id'] as String,
      requestedDate: DateTime.parse(json['requested_date'].toString()),
      requestedTime: json['requested_time'] as String,
      notes: json['notes'] as String?,
      amount: (json['amount'] as num).toDouble(),
      bookingStatus: json['booking_status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      paymobOrderId: json['paymob_order_id'] as String?,
      paymobIntentionId: json['paymob_intention_id'] as String?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'].toString())
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // This method converts the booking model into a JSON payload for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'institution_id': institutionId,
      'service_id': serviceId,
      'requested_date': requestedDate.toIso8601String().split('T').first,
      'requested_time': requestedTime,
      'notes': notes,
      'amount': amount,
      'booking_status': bookingStatus,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'paymob_order_id': paymobOrderId,
      'paymob_intention_id': paymobIntentionId,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  // This method creates a modified copy of the booking model.
  BookingModel copyWith({
    String? id,
    String? userId,
    String? institutionId,
    String? serviceId,
    DateTime? requestedDate,
    String? requestedTime,
    String? notes,
    double? amount,
    String? bookingStatus,
    String? paymentMethod,
    String? paymentStatus,
    String? paymobOrderId,
    String? paymobIntentionId,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      institutionId: institutionId ?? this.institutionId,
      serviceId: serviceId ?? this.serviceId,
      requestedDate: requestedDate ?? this.requestedDate,
      requestedTime: requestedTime ?? this.requestedTime,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymobOrderId: paymobOrderId ?? this.paymobOrderId,
      paymobIntentionId: paymobIntentionId ?? this.paymobIntentionId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}