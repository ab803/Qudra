import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:qudra_0/core/Utilies/gorouter.dart';
import 'package:qudra_0/Feature/medical_reminders/services/reminder_service.dart';
import 'package:qudra_0/Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicalRemindersViewModel(ReminderService())..loadReminders(),
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