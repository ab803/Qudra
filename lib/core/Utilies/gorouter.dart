import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Feature/Auth/forget_password/views/ForgetPasswordView.dart';
import '../../Feature/Auth/forget_password/views/ResetPasswordView.dart';
import '../../Feature/Auth/login/views/LoginView.dart';
import '../../Feature/Auth/signUp/Views/SignUpView.dart';
import '../../Feature/Chat_Bot/views/chat_bot_view.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/accessibility/views/accessibility_hub_view.dart';
import '../../Feature/bottom_nav_bar.dart';
import '../../Feature/community/presentation/community_view.dart';
import '../../Feature/emergency_assist/presentation/emergency_entry_view.dart';
import '../../Feature/emergency_assist/presentation/emergency_main_entry.dart';
import '../../Feature/institution/institution.dart';
import '../../Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import '../../Feature/profile/presentation/profile.dart';
import '../../Feature/profile/presentation/views/personal_info_view.dart';

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

      // لو مش مسجل دخول، اسمح فقط بصفحات الـ Auth العامة + splash
      if (!isLoggedIn &&
          !goingToLogin &&
          !goingToSignUp &&
          !goingToForget &&
          !goingToResetPassword &&
          !goingToSplash) {
        return '/login';
      }

      // لو مسجل دخول، امنعه من صفحات الـ Auth
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
        builder: (context, state) => PersonalInfoView(
        ),
      ),

      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatBotView(),
      ),

      GoRoute(
        path: '/accessibility',
        builder: (context, state) => const AccessibilityHubView(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainNavView(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/institution',
            builder: (context, state) => const InstitutionView(),
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