import '../models/booking_model.dart';
import '../models/booking_payment_model.dart';

// This file defines the states emitted by the booking cubit across cash and online flows.
abstract class BookingState {}

// This state is emitted before any booking action starts.
class BookingInitial extends BookingState {}

// This state is emitted while a booking request is being created.
class BookingLoading extends BookingState {}

// This state is emitted after creating an online booking session that requires checkout redirection.
class BookingSessionCreated extends BookingState {
  final String bookingId;
  final String checkoutUrl;
  final String paymentMethod;
  final String message;

  BookingSessionCreated({
    required this.bookingId,
    required this.checkoutUrl,
    required this.paymentMethod,
    required this.message,
  });
}

// This state is emitted while the app is waiting for the final booking/payment result.
class BookingProcessing extends BookingState {
  final String bookingId;
  final BookingModel? booking;
  final BookingPaymentModel? payment;

  BookingProcessing({
    required this.bookingId,
    this.booking,
    this.payment,
  });
}

// ✅ Updated: this state is emitted when polling finishes
// but the booking is still pending and the result screen should explain that.
class BookingPendingResult extends BookingState {
  final String bookingId;
  final String message;
  final BookingModel? booking;
  final BookingPaymentModel? payment;

  BookingPendingResult({
    required this.bookingId,
    required this.message,
    this.booking,
    this.payment,
  });
}

// This state is emitted when the booking is confirmed successfully.
class BookingConfirmed extends BookingState {
  final BookingModel booking;
  final BookingPaymentModel? payment;

  BookingConfirmed({
    required this.booking,
    this.payment,
  });
}

// This state is emitted when the booking or payment flow fails.
class BookingFailed extends BookingState {
  final String errorMessage;
  final BookingModel? booking;
  final BookingPaymentModel? payment;

  BookingFailed({
    required this.errorMessage,
    this.booking,
    this.payment,
  });
}

// This state is emitted when an unexpected booking error happens.
class BookingError extends BookingState {
  final String errorMessage;

  BookingError({
    required this.errorMessage,
  });
}