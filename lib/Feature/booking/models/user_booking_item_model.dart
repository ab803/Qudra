// This model represents a single booking item shown in the user's bookings list.
class UserBookingItemModel {
  final String id;
  final String institutionId;
  final String institutionName;
  final String serviceName;
  final DateTime requestedDate;
  final String requestedTime;
  final double amount;
  final String bookingStatus;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime? createdAt;
  final String? notes;

  UserBookingItemModel({
    required this.id,
    required this.institutionId,
    required this.institutionName,
    required this.serviceName,
    required this.requestedDate,
    required this.requestedTime,
    required this.amount,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.createdAt,
    this.notes,
  });
}