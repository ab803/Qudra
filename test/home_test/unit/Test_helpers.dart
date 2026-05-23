import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_cubit.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/Feature/institution/models/institution_model.dart';
import 'package:qudra_0/Feature/institution/services/institution_service.dart';




// ─────────────────────────────────────────────────────────────────────────────
// MOCK CLASSES
// ─────────────────────────────────────────────────────────────────────────────

/// Mocks AuthCubit so we can control what state is emitted in widget tests.
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

/// Mocks the institution service so network calls never happen in tests.
class MockInstitutionFeatureService extends Mock
    implements InstitutionFeatureService {}

// ─────────────────────────────────────────────────────────────────────────────
// FAKE USER MODEL
// Adjust field names to match your actual UserModel / ProfileModel.
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a fake logged-in user for testing.
///
/// Assumption: your user model has [fullName] and [disabilityType] fields.
dynamic fakeUser({
  String fullName = 'Abdullah Khairy',
  String disabilityType = 'physical',
}) {
  // If your UserModel has a factory / constructor, build it here.
  // Using a simple anonymous approach that works with duck-typing tests.
  return _FakeUser(fullName: fullName, disabilityType: disabilityType);
}

class _FakeUser {
  final String fullName;
  final String disabilityType;
  final String id;

  _FakeUser({required this.fullName, required this.disabilityType})
      : id = 'user-test-001';
}

// ─────────────────────────────────────────────────────────────────────────────
// FAKE INSTITUTION MODEL
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a minimal [InstitutionModel] for use in FutureBuilder results.
InstitutionModel fakeInstitution({
  String id = 'inst-001',
  String name = 'Test Institution',
  String category = 'physical',
}) {
  // Adjust to match your actual InstitutionModel constructor.
  return InstitutionModel(id: id, name: name,email: '', institutionType: '', location: '');
}

List<InstitutionModel> fakeInstitutionList({int count = 3}) => List.generate(
  count,
      (i) => fakeInstitution(id: 'inst-00$i', name: 'Institution $i'),
);

// ─────────────────────────────────────────────────────────────────────────────
// TEST WRAPPER
// Provides GoRouter, BLoC, and GetIt to the widget under test.
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] with everything a home-screen widget needs:
///  - MaterialApp (theme, directionality)
///  - GoRouter (for navigation assertions)
///  - BlocProvider<AuthCubit>
///
/// Pass [authCubit] to inject a mock. Pass [extraProviders] for additional BLoCs.
Widget buildTestableWidget({
  required Widget child,
  MockAuthCubit? authCubit,
  List<BlocProvider> extraProviders = const [],
  GoRouter? router,
  ThemeData? theme,
}) {
  final cubit = authCubit ?? MockAuthCubit();
  final effectiveRouter =
      router ?? _defaultRouter(child: child);

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: cubit),
      ...extraProviders,
    ],
    child: MaterialApp.router(
      routerConfig: effectiveRouter,
      theme: theme ?? ThemeData.light(),
      // Minimal localization so context.tr() falls back to key names in tests.
      localizationsDelegates: const [],
    ),
  );
}

/// A simple single-route GoRouter that renders [child] at '/'.
GoRouter _defaultRouter({required Widget child}) => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => child),
    GoRoute(path: '/emergency-entry', builder: (_, __) => const _Stub('emergency')),
    GoRoute(path: '/chat', builder: (_, __) => const _Stub('chat')),
    GoRoute(path: '/reminders', builder: (_, __) => const _Stub('reminders')),
    GoRoute(path: '/accessibility', builder: (_, __) => const _Stub('accessibility')),
    GoRoute(path: '/institution', builder: (_, __) => const _Stub('institution')),
    GoRoute(path: '/institution/:id', builder: (_, __) => const _Stub('institution_detail')),
  ],
);

/// Lightweight placeholder used as a navigation target in tests.
class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);

  @override
  Widget build(BuildContext context) => Scaffold(body: Text('stub:$label'));
}

// ─────────────────────────────────────────────────────────────────────────────
// GETIT HELPERS
// Call these in setUp / tearDown to avoid test pollution.
// ─────────────────────────────────────────────────────────────────────────────

/// Registers a mock [InstitutionFeatureService] in GetIt.
void registerMockInstitutionService(MockInstitutionFeatureService mock) {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<InstitutionFeatureService>()) {
    getIt.unregister<InstitutionFeatureService>();
  }
  getIt.registerSingleton<InstitutionFeatureService>(mock);
}

/// Clears all GetIt registrations after a test.
Future<void> resetGetIt() => GetIt.instance.reset();