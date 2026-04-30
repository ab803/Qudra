import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/Utilies/gorouter.dart';
import 'core/Utilies/getit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

// 🔥 Localization
import 'core/Services/Localization/LocalizationService.dart';
import 'core/Services/Localization/language_cubit.dart';
import 'core/Services/Localization/language_state.dart';

import 'Feature/Auth/ViewModel/auth_cubit.dart';
import 'Feature/medical_reminders/services/reminder_service.dart';
import 'Feature/medical_reminders/viewmodel/medical_reminders_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lybzbbgsumqwzmenpvow.supabase.co',
    anonKey: 'sb_publishable_Lnf83gYp257M9DN26sQ0Lg_udB4Rmoq',
  );

  setupLocator();

  final themeCubit = ThemeCubit();
  await themeCubit.loadTheme();

  runApp(MyApp(themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final ThemeCubit themeCubit;

  const MyApp({
    super.key,
    required this.themeCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: themeCubit),

        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..loadCurrentUser(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
          MedicalRemindersViewModel(ReminderService())..loadReminders(),
        ),

        BlocProvider<LanguageCubit>(
          create: (_) => LanguageCubit(),
        ),
      ],

      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              final locale = state.locale; // ✅ FIX

              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Qudra',

                // 🎨 Themes
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,

                // 🌍 Localization
                locale: locale,

                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],

                localizationsDelegates: const [
                  AppLocalizationDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // 🔁 RTL support
                builder: (context, child) {
                  return Directionality(
                    textDirection: locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  );
                },

                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}