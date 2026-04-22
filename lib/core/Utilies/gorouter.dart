import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Feature/Auth/forget_password/views/ForgetPasswordView.dart';
import '../../Feature/Auth/forget_password/views/ResetPasswordView.dart';
import '../../Feature/Auth/login/views/LoginView.dart';
import '../../Feature/Auth/signUp/Views/SignUpView.dart';
import '../../Feature/Chat_Bot/views/chat_bot_view.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/accessibility/viewModel/tips_rights_cubit.dart';
import '../../Feature/accessibility/views/accessibility_hub_view.dart';
import '../../Feature/bottom_nav_bar.dart';
import '../../Feature/community/presentation/community_view.dart';
import '../../Feature/emergency_assist/presentation/emergency_entry_view.dart';
import '../../Feature/emergency_assist/presentation/emergency_main_entry.dart';
import '../../Feature/institution/views/institution.dart';
import '../../Feature/institution/views/institution_details_view.dart';
import '../../Feature/institution/viewmodel/institution_cubit.dart';
import '../../Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import '../../Feature/profile/presentation/profile.dart';
import '../../Feature/feedback/presentation/views/feedback_view.dart';
import '../../Feature/profile/presentation/views/personal_info_view.dart';

import 'getit.dart';


import '../../Feature/booking/presentation/views/booking_card_view.dart';
import '../../Feature/booking/presentation/views/booking_cash_view.dart';
import '../../Feature/booking/presentation/views/booking_checkout_view.dart';
import '../../Feature/booking/presentation/views/booking_payment_method_view.dart';
import '../../Feature/booking/presentation/views/booking_processing_view.dart';
import '../../Feature/booking/presentation/views/booking_result_view.dart';
import '../../Feature/booking/presentation/views/booking_wallet_view.dart';
import '../../Feature/booking/viewmodel/booking_cubit.dart';
import '../../Feature/booking/models/booking_model.dart';
import '../../Feature/booking/models/booking_payment_model.dart';
import '../../Feature/institution/models/institution_model.dart';
import '../../Feature/institution/models/service_model.dart';

import '../../Feature/booking/presentation/views/user_bookings_view.dart';
import '../../Feature/booking/viewmodel/user_bookings_cubit.dart';

import '../../Feature/profile/presentation/views/app_guidelines_view.dart';


class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final bool isLoggedIn = user != null;
      final location = state.matchedLocation;

      final goingToLogin = location == '/login';
      final goingToSignUp = location == '/signUp';
      final goingToForget = location == '/forget';
      final goingToResetPassword = location == '/resetPassword';
      final goingToSplash = location == '/splash';

      // Block protected routes when user is not logged in
      if (!isLoggedIn &&
          !goingToLogin &&
          !goingToSignUp &&
          !goingToForget &&
          !goingToResetPassword &&
          !goingToSplash) {
        return '/login';
      }

      // Prevent logged-in user from opening auth screens
      if (isLoggedIn &&
          (goingToLogin ||
              goingToSignUp ||
              goingToForget ||
              goingToResetPassword)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LogInView(),
      ),
      GoRoute(
        path: '/signUp',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: '/forget',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: '/resetPassword',
        builder: (context, state) {
          final email = state.extra as String;
          return ResetPasswordView(email: email);
        },
      ),
      GoRoute(
        path: '/emergency-entry',
        builder: (context, state) => EmergencyEntryView(
          mainScreenBuilder: (_) => const EmergencyMainEntry(),
        ),
      ),
      GoRoute(
        path: '/personal',
        builder: (context, state) => const PersonalInfoView(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatBotView(),
      ),
      GoRoute(
        path: '/accessibility',
        builder: (context, state) => BlocProvider<RightstipsCubit>(
          create: (_) => getIt<RightstipsCubit>(),
          child: const AccessibilityHubView(),
        ),
      ),

      GoRoute(
        path: '/AppGuidelines',
        builder: (context, state) => const AppGuidelinesView(),
      ),







      // This route opens the booking checkout screen before payment selection.
      GoRoute(
        path: '/booking/checkout',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final institution = args['institution'] as InstitutionModel;
          final service = args['service'] as InstitutionServiceModel;

          return BookingCheckoutView(
            institution: institution,
            service: service,
          );
        },
      ),

      // This route opens the booking payment method selection screen.
      GoRoute(
        path: '/booking/payment-method',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final institution = args['institution'] as InstitutionModel;
          final service = args['service'] as InstitutionServiceModel;
          final requestedDate = args['requestedDate'] as DateTime;
          final requestedTime = args['requestedTime'] as String;
          final notes = args['notes'] as String?;

          return BookingPaymentMethodView(
            institution: institution,
            service: service,
            requestedDate: requestedDate,
            requestedTime: requestedTime,
            notes: notes,
          );
        },
      ),

      // This route opens the card payment confirmation screen with a fresh booking cubit instance.
      GoRoute(
        path: '/booking/card',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final institution = args['institution'] as InstitutionModel;
          final service = args['service'] as InstitutionServiceModel;
          final requestedDate = args['requestedDate'] as DateTime;
          final requestedTime = args['requestedTime'] as String;
          final notes = args['notes'] as String?;

          return BlocProvider<BookingCubit>(
            create: (_) => getIt<BookingCubit>(),
            child: BookingCardView(
              institution: institution,
              service: service,
              requestedDate: requestedDate,
              requestedTime: requestedTime,
              notes: notes,
            ),
          );
        },
      ),

      // This route opens the wallet payment confirmation screen with a fresh booking cubit instance.
      GoRoute(
        path: '/booking/wallet',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final institution = args['institution'] as InstitutionModel;
          final service = args['service'] as InstitutionServiceModel;
          final requestedDate = args['requestedDate'] as DateTime;
          final requestedTime = args['requestedTime'] as String;
          final notes = args['notes'] as String?;

          return BlocProvider<BookingCubit>(
            create: (_) => getIt<BookingCubit>(),
            child: BookingWalletView(
              institution: institution,
              service: service,
              requestedDate: requestedDate,
              requestedTime: requestedTime,
              notes: notes,
            ),
          );
        },
      ),

      // This route opens the cash confirmation screen with a fresh booking cubit instance.
      GoRoute(
        path: '/booking/cash',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final institution = args['institution'] as InstitutionModel;
          final service = args['service'] as InstitutionServiceModel;
          final requestedDate = args['requestedDate'] as DateTime;
          final requestedTime = args['requestedTime'] as String;
          final notes = args['notes'] as String?;

          return BlocProvider<BookingCubit>(
            create: (_) => getIt<BookingCubit>(),
            child: BookingCashView(
              institution: institution,
              service: service,
              requestedDate: requestedDate,
              requestedTime: requestedTime,
              notes: notes,
            ),
          );
        },
      ),

      // This route opens the booking processing screen and polls the final booking status.
      GoRoute(
        path: '/booking/processing',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final bookingId = args['bookingId'] as String;

          return BlocProvider<BookingCubit>(
            create: (_) => getIt<BookingCubit>(),
            child: BookingProcessingView(
              bookingId: bookingId,
            ),
          );
        },
      ),

      // This route opens the final booking result screen after success or failure.
      GoRoute(
        path: '/booking/result',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final bookingId = args['bookingId'] as String;

          return BookingResultView(
            bookingId: bookingId,
          );
        },
      ),


      // This route opens the current user's bookings history page.
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<UserBookingsCubit>()..loadCurrentUserBookings(),
            child: const UserBookingsView(),
          );
        },
      ),


      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackView(),
      ),

      // Institution details route
      GoRoute(
        path: '/institution/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => getIt<InstitutionCubit>(),
            child: InstitutionDetailsView(institutionId: id),
          );
        },
      ),




      ShellRoute(
        builder: (context, state, child) {
          return MainNavView(child: child);
        },
        routes: [
          // Provide subscription state to home widgets
          GoRoute(
            path: '/home',
            builder: (context, state) {
              return const HomeView();
            },
          ),

  GoRoute(
  path: '/institution',
  builder: (context, state) {
  // This query parameter carries the initial search text from the home search bar.
  final initialQuery = state.uri.queryParameters['q'] ?? '';

  return BlocProvider(
  create: (_) => getIt<InstitutionCubit>(),
  child: InstitutionView(initialQuery: initialQuery),
  );
  },
  ),



          GoRoute(
            path: '/reminders',
            builder: (context, state) => const MedicalRemindersView(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
  );
}
