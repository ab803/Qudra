import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Feature/Chat_Bot/views/chat_bot_view.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/accessibility/views/accessibility_hub_view.dart';
import '../../Feature/bottom_nav_bar.dart';
import '../../Feature/community/communityView.dart';
import '../../Feature/emergency_call/presentation/views/emergency_help_view.dart';
import '../../Feature/institution/institution.dart';
import '../../Feature/medical_reminder/medical_reminders.dart';
import '../../Feature/profile/profile.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [

      /// Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),

      GoRoute(
        path: '/emergency-call',
        builder: (context, state) => const EmergencyHelpView(),
      ),


      /// Chat Bot
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatBotView(),
      ),

      // Accessibility
      GoRoute(
        path: '/accessibility',
        builder: (context, state) => const AccessibilityHubView(),
      ),


  /// Bottom Navigation Shell
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
            builder: (context, state) => const medicalRemindersView(),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),

          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityView(),
          ),

        ],
      ),
    ],
  );
}
