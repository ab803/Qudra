import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_cubit.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';
import 'package:qudra_0/core/Services/Localization/language_cubit.dart';
import 'package:qudra_0/core/Services/Localization/language_state.dart';

// This mock simulates auth cubit behavior in widget tests.
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

// This mock simulates language cubit behavior in widget tests.
class MockLanguageCubit extends MockCubit<LanguageState>
    implements LanguageCubit {}

// This setup registers fallback values needed by mocktail.
void registerProfileFallbackValues() {
  registerFallbackValue(AuthInitial());
  registerFallbackValue(const LanguageInitial());
}

// This helper builds a localized MaterialApp for profile widget tests.
Widget buildProfileTestApp({
  required Widget child,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizationDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
    ],
    home: Scaffold(body: child),
  );
}

// This helper pumps a widget with localization support.
Future<void> pumpProfileWidget(
    WidgetTester tester, {
      required Widget child,
    }) async {
  await tester.pumpWidget(
    buildProfileTestApp(child: child),
  );
}

// This helper builds a router app used by AppGuidelinesView tests.
Widget buildProfileRouterApp({
  required GoRouter router,
}) {
  return MaterialApp.router(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizationDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('ar'),
    ],
    routerConfig: router,
  );
}