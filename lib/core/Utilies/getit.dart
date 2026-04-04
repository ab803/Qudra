import 'package:get_it/get_it.dart';
import '../../Feature/Auth/AuhRepo/AuthRepo.dart';
import '../../Feature/Auth/AuhRepo/AuthRepoImplement.dart';
import '../../Feature/Auth/ViewModel/auth_cubit.dart';
import '../Services/supabase/AuthService.dart';
import '../Services/supabase/peopleWithDisabilityService.dart';


final GetIt getIt = GetIt.instance;

void setupLocator() {

  // ── Step 1: AuthService ─────────────────
  getIt.registerLazySingleton<AuthService>(
        () => AuthService(),
  );

  // ── Step 2: PeopleWithDisabilityService ─
  getIt.registerLazySingleton<PeopleWithDisabilityService>(
        () => PeopleWithDisabilityService(
      authService: getIt<AuthService>(),
    ),
  );

  // ── Step 3: Repository ──────────────────
  getIt.registerLazySingleton<IPeopleWithDisabilityRepository>(
        () => PeopleWithDisabilityRepositoryImpl(
      service: getIt<PeopleWithDisabilityService>(), reset: getIt<AuthService>(),
    ),
  );


  // ── Cubits ──────────────────────────────
  getIt.registerFactory<AuthCubit>(
        () => AuthCubit(),
  );
}