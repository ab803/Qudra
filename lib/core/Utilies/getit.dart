import 'package:get_it/get_it.dart';

import '../../Feature/Auth/AuhRepo/AuthRepo.dart';
import '../../Feature/Auth/AuhRepo/AuthRepoImplement.dart';
import '../../Feature/Auth/ViewModel/auth_cubit.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepo.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepoImpl.dart';
import '../../Feature/institution/services/institution_service.dart';
import '../../Feature/institution/viewmodel/institution_cubit.dart';
import '../Services/Gemini/GeminiService.dart';
import '../Services/supabase/AuthService.dart';
import '../Services/supabase/peopleWithDisabilityService.dart';
import '../../Feature/booking/services/booking_service.dart';
import '../../Feature/booking/viewmodel/booking_cubit.dart';
import '../../Feature/booking/services/user_bookings_service.dart';
import '../../Feature/booking/viewmodel/user_bookings_cubit.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Auth service
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Gemini chat service
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

  // User profile service
  getIt.registerLazySingleton<PeopleWithDisabilityService>(
        () => PeopleWithDisabilityService(
      authService: getIt<AuthService>(),
    ),
  );

  // User auth repository
  getIt.registerLazySingleton<IPeopleWithDisabilityRepository>(
        () => PeopleWithDisabilityRepositoryImpl(
      service: getIt<PeopleWithDisabilityService>(),
      reset: getIt<AuthService>(),
    ),
  );

  // Auth cubit
  getIt.registerFactory<AuthCubit>(() => AuthCubit());

  // Chat repository
  getIt.registerLazySingleton<IChatRepository>(
        () => ChatRepositoryImpl(
      service: getIt<GeminiService>(),
    ),
  );

  // Institution feature
  getIt.registerLazySingleton<InstitutionFeatureService>(
        () => InstitutionFeatureService(),
  );
  getIt.registerFactory<InstitutionCubit>(
        () => InstitutionCubit(getIt<InstitutionFeatureService>()),
  );

  // Booking feature
  getIt.registerLazySingleton<BookingService>(() => BookingService());
  getIt.registerFactory<BookingCubit>(
        () => BookingCubit(getIt<BookingService>()),
  );

  // User bookings
  getIt.registerLazySingleton<UserBookingsService>(
        () => UserBookingsService(),
  );
  getIt.registerFactory<UserBookingsCubit>(
        () => UserBookingsCubit(getIt<UserBookingsService>()),
  );
}