import '../models/user_booking_item_model.dart';
abstract class UserBookingsState {}

// This state is emitted before any loading starts.
class UserBookingsInitial extends UserBookingsState {}

// This state is emitted while user bookings are being loaded.
class UserBookingsLoading extends UserBookingsState {}

// This state is emitted after loading the current user's bookings successfully.
class UserBookingsLoaded extends UserBookingsState {
  final List<UserBookingItemModel> bookings;

  UserBookingsLoaded({
    required this.bookings,
  });
}

// This state is emitted when loading user bookings fails.
class UserBookingsError extends UserBookingsState {
  final String errorMessage;

  UserBookingsError({
    required this.errorMessage,
  });
}
