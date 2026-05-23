import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_cubit.dart';
import 'package:qudra_0/Feature/Auth/ViewModel/auth_state.dart';
import 'package:qudra_0/Feature/Auth/forget_password/views/ForgetPasswordView.dart';
import 'package:qudra_0/Feature/Auth/login/views/LoginView.dart';
import 'package:qudra_0/Feature/Auth/signUp/Views/SignUpView.dart';
import 'package:qudra_0/Feature/Auth/widgets/AuthActionButton.dart';
import 'package:qudra_0/Feature/Auth/widgets/CustomDropdown.dart';
import 'package:qudra_0/Feature/Auth/widgets/CustomTextField.dart';
import 'package:qudra_0/core/Models/people_with_disabilityModel.dart';


// ─── Mock ────────────────────────────────────────────────────────────────────
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

// ─── Fixture ─────────────────────────────────────────────────────────────────
final _tUser = PeopleWithDisabilityModel(
  id: 'user-123',
  createdAt: DateTime(2024),
  fullName: 'Ahmed Ali',
  phone: '01012345678',
  email: 'ahmed@example.com',
  disabilityType: 'Visual',
  password: 'secret123',
  responsiblePerson: 'Mohamed Ali',
  gender: 'Male',
  age: 25,
);

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Wraps a widget in the minimal scaffolding needed: BlocProvider, GoRouter,
/// MaterialApp, and basic localization so context.tr() resolves strings.
Widget _wrapWithRouter({
  required Widget child,
  required MockAuthCubit cubit,
  String initialLocation = '/',
  List<GoRoute> extraRoutes = const [],
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('home'))),
      GoRoute(path: '/login', builder: (_, __) => const Scaffold(body: Text('login'))),
      GoRoute(path: '/signUp', builder: (_, __) => const Scaffold(body: Text('signUp'))),
      GoRoute(path: '/forget', builder: (_, __) => const Scaffold(body: Text('forget'))),
      GoRoute(
        path: '/resetPassword',
        builder: (_, state) => Scaffold(body: Text('reset-${state.extra}')),
      ),
      ...extraRoutes,
    ],
  );

  return BlocProvider<AuthCubit>.value(
    value: cubit,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// LogInView
// ════════════════════════════════════════════════════════════════════════════
void main() {
  group('LogInView', () {
    late MockAuthCubit cubit;

    setUp(() {
      cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(AuthInitial());
    });

    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(child: const LogInView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('shows CircularProgressIndicator when state is AuthLoading',
            (tester) async {
          when(() => cubit.state).thenReturn(AuthLoading());

          await tester.pumpWidget(
            _wrapWithRouter(child: const LogInView(), cubit: cubit),
          );
          await tester.pump(); // one frame — don't settle so spinner is visible

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('calls login on cubit when button is tapped with valid input',
            (tester) async {
          when(() => cubit.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});

          await tester.pumpWidget(
            _wrapWithRouter(child: const LogInView(), cubit: cubit),
          );
          await tester.pumpAndSettle();

          // Fill email field
          await tester.enterText(
            find.byType(TextFormField).first,
            'ahmed@example.com',
          );
          // Fill password field
          await tester.enterText(
            find.byType(TextFormField).last,
            'secret123',
          );

          // Tap the login/submit button
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          verify(() => cubit.login(
            email: 'ahmed@example.com',
            password: 'secret123',
          )).called(1);
        });

    testWidgets('navigates to /home on LoginSuccess', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([AuthLoading(), LoginSuccess(user: _tUser)]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(
        _wrapWithRouter(child: const LogInView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('shows snackbar on AuthFailure', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([
          AuthLoading(),
          AuthFailure(errorMessage: 'invalid login credentials'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(
        _wrapWithRouter(child: const LogInView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('does not call login when email is empty', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(child: const LogInView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      // Leave fields blank, tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verifyNever(() => cubit.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ));
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // SignUpView
  // ════════════════════════════════════════════════════════════════════════════
  group('SignUpView', () {
    late MockAuthCubit cubit;

    setUp(() {
      cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(AuthInitial());
    });

    testWidgets('renders all required input fields', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(child: const SignUpView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      // Full name, phone, email, password, responsible person, age = 6 text fields
      expect(find.byType(TextFormField), findsAtLeastNWidgets(5));
      // Gender + DisabilityType dropdowns
      expect(find.byType(DropdownButton<String>), findsNWidgets(2));
    });

    testWidgets('shows snackbar when fields are empty and button tapped',
            (tester) async {
          await tester.pumpWidget(
            _wrapWithRouter(child: const SignUpView(), cubit: cubit),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          // Should see validation snackbar, NOT call signUp
          expect(find.byType(SnackBar), findsOneWidget);
          verifyNever(() => cubit.signUp(
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            disabilityType: any(named: 'disabilityType'),
            responsiblePerson: any(named: 'responsiblePerson'),
            gender: any(named: 'gender'),
            age: any(named: 'age'),
          ));
        });

    testWidgets('navigates to /home on SignUpSuccess', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([AuthLoading(), SignUpSuccess(user: _tUser)]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(
        _wrapWithRouter(child: const SignUpView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('shows snackbar on AuthFailure', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable([
          AuthLoading(),
          AuthFailure(errorMessage: 'already registered'),
        ]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(
        _wrapWithRouter(child: const SignUpView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows spinner when state is AuthLoading', (tester) async {
      when(() => cubit.state).thenReturn(AuthLoading());

      await tester.pumpWidget(
        _wrapWithRouter(child: const SignUpView(), cubit: cubit),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // ForgotPasswordView
  // ════════════════════════════════════════════════════════════════════════════
  group('ForgotPasswordView', () {
    late MockAuthCubit cubit;

    setUp(() {
      cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(AuthInitial());
    });

    testWidgets('renders email field', (tester) async {
      await tester.pumpWidget(
        _wrapWithRouter(child: const ForgotPasswordView(), cubit: cubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('navigates to /resetPassword on ForgotPasswordSuccess',
            (tester) async {
          whenListen(
            cubit,
            Stream.fromIterable([
              AuthLoading(),
              ForgotPasswordSuccess(email: 'ahmed@example.com'),
            ]),
            initialState: AuthInitial(),
          );

          await tester.pumpWidget(
            _wrapWithRouter(child: const ForgotPasswordView(), cubit: cubit),
          );
          await tester.pumpAndSettle();

          // GoRouter passes email via extra; our stub renders 'reset-<email>'
          expect(find.textContaining('reset-ahmed@example.com'), findsOneWidget);
        });

    testWidgets('calls forgotPassword on valid email submission',
            (tester) async {
          when(() => cubit.forgotPassword(email: any(named: 'email')))
              .thenAnswer((_) async {});

          await tester.pumpWidget(
            _wrapWithRouter(child: const ForgotPasswordView(), cubit: cubit),
          );
          await tester.pumpAndSettle();

          await tester.enterText(
              find.byType(TextFormField), 'ahmed@example.com');
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          verify(() => cubit.forgotPassword(email: 'ahmed@example.com')).called(1);
        });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // AuthButton widget
  // ════════════════════════════════════════════════════════════════════════════
  group('AuthButton', () {
    late MockAuthCubit cubit;

    setUp(() {
      cubit = MockAuthCubit();
    });

    Widget _buildButton({VoidCallback? onPressed}) {
      return BlocProvider<AuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          home: Scaffold(
            body: AuthButton(label: 'Login', onPressed: onPressed),
          ),
        ),
      );
    }

    testWidgets('renders label text', (tester) async {
      when(() => cubit.state).thenReturn(AuthInitial());
      await tester.pumpWidget(_buildButton());
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when state is AuthLoading',
            (tester) async {
          when(() => cubit.state).thenReturn(AuthLoading());
          await tester.pumpWidget(_buildButton());
          await tester.pump();

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('Login'), findsNothing);
        });

    testWidgets('calls onPressed when not loading', (tester) async {
      when(() => cubit.state).thenReturn(AuthInitial());
      var pressed = false;

      await tester.pumpWidget(_buildButton(onPressed: () => pressed = true));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when loading', (tester) async {
      when(() => cubit.state).thenReturn(AuthLoading());
      var pressed = false;

      await tester.pumpWidget(_buildButton(onPressed: () => pressed = true));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // CustomTextField widget
  // ════════════════════════════════════════════════════════════════════════════
  group('CustomTextField', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    Widget _buildField({
      bool obscureText = false,
      String? Function(String?)? validator,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            child: CustomTextField(
              controller: controller,
              label: 'Email',
              hint: 'Enter email',
              keyboardType: TextInputType.emailAddress,
              obscureText: obscureText,
              validator: validator,
            ),
          ),
        ),
      );
    }

    testWidgets('renders label and hint', (tester) async {
      await tester.pumpWidget(_buildField());
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('reflects text entered by user', (tester) async {
      await tester.pumpWidget(_buildField());
      await tester.enterText(find.byType(TextFormField), 'hello@test.com');
      expect(controller.text, 'hello@test.com');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(_buildField(obscureText: true));
      final textField = tester.widget<EditableText>(find.byType(EditableText));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('shows validation error text when validator fails',
            (tester) async {
          await tester.pumpWidget(_buildField(
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ));

          // Trigger validation
          final formState = tester
              .state<FormState>(find.byType(Form));
          formState.validate();
          await tester.pump();

          expect(find.text('Required'), findsOneWidget);
        });
  });

  // ════════════════════════════════════════════════════════════════════════════
  // CustomDropdown widget
  // ════════════════════════════════════════════════════════════════════════════
  group('CustomDropdown', () {
    testWidgets('renders label and hint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown(
              label: 'Gender',
              hint: 'Select gender',
              value: null,
              items: ['Male', 'Female'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Select gender'), findsOneWidget);
    });

    testWidgets('calls onChanged with selected value', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDropdown(
              label: 'Gender',
              hint: 'Select gender',
              value: null,
              items: ['Male', 'Female'],
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );

      // Open the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select 'Male'
      await tester.tap(find.text('Male').last);
      await tester.pumpAndSettle();

      expect(selected, 'Male');
    });

    testWidgets('uses itemLabelBuilder to translate displayed text',
            (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomDropdown(
                  label: 'Gender',
                  hint: 'Select',
                  value: null,
                  items: ['Male', 'Female'],
                  itemLabelBuilder: (v) => v == 'Male' ? 'ذكر' : 'أنثى',
                  onChanged: (_) {},
                ),
              ),
            ),
          );

          // Open dropdown to see items
          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();

          expect(find.text('ذكر'), findsAtLeastNWidgets(1));
          expect(find.text('أنثى'), findsAtLeastNWidgets(1));
        });
  });
}