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
import '../../Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import '../../Feature/profile/presentation/views/app_guidelines_view.dart';
import '../../Feature/profile/presentation/views/feedback_view.dart';
import '../../Feature/profile/presentation/views/my_subscriptions_view.dart';
import '../../Feature/profile/presentation/views/personal_info_view.dart';
import '../../Feature/profile/presentation/profile.dart';

class AppRouter {
  // Helper method to create the animated transition
  static CustomTransitionPage _buildPageWithAnimation(
      BuildContext context, GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      // Change transition duration here if needed
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        /// FADE TRANSITION (Currently Active)
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );


      },
    );
  }

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      /// Splash
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(context, state, const SplashView()),
      ),

      GoRoute(
        path: '/emergency-call',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(context, state, const EmergencyHelpView()),
      ),

      /// Chat Bot
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(context, state, const ChatBotView()),
      ),

      // Accessibility
      GoRoute(
        path: '/accessibility',
        pageBuilder: (context, state) => _buildPageWithAnimation(
            context, state, const AccessibilityHubView()),
      ),
      GoRoute(
        path: '/personal',
        pageBuilder: (context, state) => _buildPageWithAnimation(
            context, state, const PersonalInfoView()),
      ),
      GoRoute(
        path: '/AppGuidelines',
        pageBuilder: (context, state) => _buildPageWithAnimation(
            context, state, const AppGuidelinesView()),
      ),
      GoRoute(
        path: '/Feedback',
        pageBuilder: (context, state) => _buildPageWithAnimation(
            context, state, const FeedbackView()),
      ),
      GoRoute(
        path: '/MySubscriptions',
        pageBuilder: (context, state) => _buildPageWithAnimation(
            context, state, const MySubscriptionsView()),
      ),


      /// Bottom Navigation Shell
      ShellRoute(
        // Note: For ShellRoute, if you want the Shell itself to animate in,
        // you can also use pageBuilder here. Usually, builder is fine
        // if only the internal tabs animate.
        builder: (context, state, child) {
          return MainNavView(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                _buildPageWithAnimation(context, state, const HomeView()),
          ),
          GoRoute(
            path: '/institution',
            pageBuilder: (context, state) =>
                _buildPageWithAnimation(context, state, const InstitutionView()),
          ),
          GoRoute(
            path: '/reminders',
            pageBuilder: (context, state) => _buildPageWithAnimation(
                context, state, const MedicalRemindersView()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _buildPageWithAnimation(context, state, const ProfileView()),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) =>
                _buildPageWithAnimation(context, state, const CommunityView()),
          ),
        ],
      ),
    ],
  );
}