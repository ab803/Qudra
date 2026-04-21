import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/Utilies/gorouter.dart';
import 'core/Utilies/getit.dart';

import 'Feature/Auth/ViewModel/auth_cubit.dart';
import 'Feature/medical_reminders/services/reminder_service.dart';
import 'Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lybzbbgsumqwzmenpvow.supabase.co',
    anonKey: "sb_publishable_Lnf83gYp257M9DN26sQ0Lg_udB4Rmoq",
  );

  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// ✅ BLoC
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..loadCurrentUser(),
        ),

        /// ✅ Provider
        ChangeNotifierProvider(
          create: (_) =>
          MedicalRemindersViewModel(ReminderService())..loadReminders(),
        ),
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