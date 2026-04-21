// This model represents a payment record linked to a service booking.
class BookingPaymentModel {
  final String id;
  final String bookingId;
  final String provider;
  final String paymentMethod;
  final String paymentStatus;
  final double amount;
  final String? transactionRef;
  final String? paymobOrderId;
  final String? paymobIntentionId;
  final String? paymobTransactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingPaymentModel({
    required this.id,
    required this.bookingId,
    required this.provider,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    this.transactionRef,
    this.paymobOrderId,
    this.paymobIntentionId,
    this.paymobTransactionId,
    this.createdAt,
    this.updatedAt,
  });

  // This factory creates a booking payment model from a Supabase row.
  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingPaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      provider: json['provider'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionRef: json['transaction_ref'] as String?,
      paymobOrderId: json['paymob_order_id'] as String?,
      paymobIntentionId: json['paymob_intention_id'] as String?,
      paymobTransactionId: json['paymob_transaction_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  // This method converts the booking payment model into a JSON payload for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'provider': provider,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'amount': amount,
      'transaction_ref': transactionRef,
      'paymob_order_id': paymobOrderId,
      'paymob_intention_id': paymobIntentionId,
      'paymob_transaction_id': paymobTransactionId,
    };
  }

  // This method creates a modified copy of the booking payment model.
  BookingPaymentModel copyWith({
    String? id,
    String? bookingId,
    String? provider,
    String? paymentMethod,
    String? paymentStatus,
    double? amount,
    String? transactionRef,
    String? paymobOrderId,
    String? paymobIntentionId,
    String? paymobTransactionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingPaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      provider: provider ?? this.provider,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amount: amount ?? this.amount,
      transactionRef: transactionRef ?? this.transactionRef,
      paymobOrderId: paymobOrderId ?? this.paymobOrderId,
      paymobIntentionId: paymobIntentionId ?? this.paymobIntentionId,
      paymobTransactionId: paymobTransactionId ?? this.paymobTransactionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}