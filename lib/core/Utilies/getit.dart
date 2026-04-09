import 'package:get_it/get_it.dart';
import '../../Feature/Auth/AuhRepo/AuthRepo.dart';
import '../../Feature/Auth/AuhRepo/AuthRepoImplement.dart';
import '../../Feature/Auth/ViewModel/auth_cubit.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepo.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepoImpl.dart';
import '../Services/Gemini/GeminiService.dart';
import '../Services/supabase/AuthService.dart';
import '../Services/supabase/peopleWithDisabilityService.dart';


final GetIt getIt = GetIt.instance;

void setupLocator() {

  // ── Step 1: AuthService ─────────────────
  getIt.registerLazySingleton<AuthService>(
        () => AuthService(),
  );
  // GeminiService
  getIt.registerLazySingleton<GeminiService>(() => GeminiService());

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



  getIt.registerLazySingleton<IChatRepository>(
          () => ChatRepositoryImpl(service: getIt<GeminiService>()));
}