import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/models/service_model.dart';
import 'package:qudra_0/Feature/institution/services/institution_service.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_cubit.dart';
import 'package:qudra_0/Feature/institution/viewmodel/institution_state.dart';
import 'package:qudra_0/core/Services/Localization/LocalizationService.dart';

// This mock simulates institution service behavior in tests.
class MockInstitutionFeatureService extends Mock
    implements InstitutionFeatureService {}

// This mock cubit simulates institution cubit behavior in widget tests.
class MockInstitutionCubit extends MockCubit<InstitutionState>
    implements InstitutionCubit {}

// This helper creates a fake institution model for tests.
InstitutionModel makeInstitution({
  String id = 'inst-1',
  String name = 'Hope Center',
  String email = 'hope@example.com',
  String? phone = '01000000000',
  String? address = 'Cairo',
  String? description = 'Helpful support center',
  String institutionType = 'Support Center',
  String location = 'https://maps.google.com/?q=cairo',
  DateTime? createdAt,
}) {
  return InstitutionModel(
    id: id,
    name: name,
    email: email,
    phone: phone,
    address: address,
    description: description,
    institutionType: institutionType,
    location: location,
    createdAt: createdAt,
  );
}

// This helper creates a fake institution service model for tests.
InstitutionServiceModel makeInstitutionService({
  String id = 'srv-1',
  String institutionId = 'inst-1',
  String name = 'Speech Therapy',
  String category = 'Therapy',
  String? description = 'Therapy session',
  List<String> supportedDisabilities = const ['Hearing'],
  double price = 150,
  bool isFree = false,
  int durationMinutes = 60,
  String locationMode = 'on_site',
  String bookingType = 'instant_slot',
  String? availabilityNotes = 'Available daily',
  List<String> workingDays = const ['Sunday', 'Monday'],
  String? workingStartTime = '09:00:00',
  String? workingEndTime = '17:00:00',
  bool isActive = true,
  DateTime? createdAt,
}) {
  return InstitutionServiceModel(
    id: id,
    institutionId: institutionId,
    name: name,
    category: category,
    description: description,
    supportedDisabilities: supportedDisabilities,
    price: price,
    isFree: isFree,
    durationMinutes: durationMinutes,
    locationMode: locationMode,
    bookingType: bookingType,
    availabilityNotes: availabilityNotes,
    workingDays: workingDays,
    workingStartTime: workingStartTime,
    workingEndTime: workingEndTime,
    isActive: isActive,
    createdAt: createdAt,
  );
}

// This helper builds a localized MaterialApp wrapper.
Widget buildInstitutionTestApp({
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
Future<void> pumpInstitutionWidget(
    WidgetTester tester, {
      required Widget child,
    }) async {
  await tester.pumpWidget(
    buildInstitutionTestApp(child: child),
  );
}

// This helper builds a router app used by integration tests.
Widget buildInstitutionRouterApp({
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