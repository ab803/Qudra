import 'package:get_it/get_it.dart';
import 'package:qudra_0/Feature/accessibility/viewModel/tips_rights_cubit.dart';
import 'package:qudra_0/core/Services/Supabase/tips&rightsService.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Feature/Auth/AuhRepo/AuthRepo.dart';
import '../../Feature/Auth/AuhRepo/AuthRepoImplement.dart';
import '../../Feature/Auth/ViewModel/auth_cubit.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepo.dart';
import '../../Feature/Chat_Bot/AIRepo/AIRepoImpl.dart';
import '../../Feature/accessibility/repo/Rights&tipsRepo.dart';
import '../Services/Gemini/GeminiService.dart';
import '../Services/supabase/AuthService.dart';
import '../Services/supabase/peopleWithDisabilityService.dart';


final GetIt getIt = GetIt.instance;

void setupLocator() {

  getIt.registerLazySingleton<SupabaseClient>(
        () => Supabase.instance.client,
  );

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

  // in your GetIt setup (injection_container.dart or similar)
  getIt.registerLazySingleton<RightstipsService>(
        () => RightstipsService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<RightstipsRepository>(
        () => RightstipsRepository(getIt<RightstipsService>()),
  );

  getIt.registerFactory<RightstipsCubit>(
        () => RightstipsCubit(getIt<RightstipsRepository>()),
  );

}