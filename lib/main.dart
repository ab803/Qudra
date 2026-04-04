import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qudra_0/core/Utilies/gorouter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Feature/Auth/ViewModel/auth_cubit.dart';
import 'core/Utilies/getit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://lybzbbgsumqwzmenpvow.supabase.co",
    anonKey: "sb_publishable_Lnf83gYp257M9DN26sQ0Lg_udB4Rmoq",
  );

  // ✅ Must be before runApp so cubits can resolve dependencies
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        // add more cubits here as your app grows
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Qudra',
        theme: ThemeData(useMaterial3: true),
        routerConfig: AppRouter.router,
      ),
    );
  }
}