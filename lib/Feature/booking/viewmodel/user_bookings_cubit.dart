import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/user_bookings_service.dart';
import 'user_bookings_state.dart';

class UserBookingsCubit extends Cubit<UserBookingsState> {
  final UserBookingsService _service;

  UserBookingsCubit(this._service) : super(UserBookingsInitial());

  // This method fetches the current user's bookings list from Supabase.
  Future<void> loadCurrentUserBookings() async {
    emit(UserBookingsLoading());

    try {
      final bookings = await _service.getCurrentUserBookings();
      emit(
        UserBookingsLoaded(bookings: bookings),
      );
    } catch (e) {
      emit(
        UserBookingsError(
          errorMessage: e.toString(),
        ),
      );
    }
  }
}



