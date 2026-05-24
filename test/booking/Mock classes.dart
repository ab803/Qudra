import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/booking/services/booking_service.dart';
import 'package:qudra_0/Feature/booking/services/user_bookings_service.dart';
import 'package:qudra_0/Feature/booking/viewmodel/booking_cubit.dart';
import 'package:qudra_0/Feature/booking/viewmodel/user_bookings_cubit.dart';


// ---------------------------------------------------------------------------
// Service mocks
// ---------------------------------------------------------------------------

class MockBookingService extends Mock implements BookingService {}

class MockUserBookingsService extends Mock implements UserBookingsService {}

// ---------------------------------------------------------------------------
// Cubit mocks  (used in widget tests to drive BlocConsumer / BlocBuilder)
// ---------------------------------------------------------------------------

class MockBookingCubit extends Mock implements BookingCubit {}

class MockUserBookingsCubit extends Mock implements UserBookingsCubit {}

// ---------------------------------------------------------------------------
// Fallback values required by mocktail for non-nullable custom types
// ---------------------------------------------------------------------------

void registerFallbacks() {
  // Register any custom types that mocktail cannot auto-create.
  // Add more registerFallbackValue() calls here as new types are introduced.
}