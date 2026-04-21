import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../Feature/Auth/forget_password/views/ForgetPasswordView.dart';
import '../../Feature/Auth/forget_password/views/ResetPasswordView.dart';
import '../../Feature/Auth/login/views/LoginView.dart';
import '../../Feature/Auth/signUp/Views/SignUpView.dart';
import '../../Feature/Chat_Bot/views/chat_bot_view.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/accessibility/repo/Rights&tipsRepo.dart';
import '../../Feature/accessibility/viewModel/tips_rights_cubit.dart';
import '../../Feature/accessibility/views/accessibility_hub_view.dart';
import '../../Feature/bottom_nav_bar.dart';
import '../../Feature/community/communityView.dart';
import '../../Feature/emergency_call/presentation/views/emergency_help_view.dart';
import '../../Feature/institution/institution.dart';
import '../../Feature/medical_reminders/presentation/views/medical_reminders_view.dart';
import '../../Feature/profile/presentation/profile.dart';
import 'getit.dart';

class AppRouter {

  /// 🔥 Reusable Transition (Slide from right)
  static CustomTransitionPage buildPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {

        const begin = Offset(1, 0); // من اليمين
        const end = Offset.zero;

        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// 🔥 Fade Transition (لـ Auth)
  static CustomTransitionPage fadePage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
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
            fadePage(child: const SplashView(), state: state),
      ),

      /// Emergency
      GoRoute(
        path: '/emergency-call',
        pageBuilder: (context, state) =>
            buildPage(child: const EmergencyHelpView(), state: state),
      ),

      /// Chat Bot
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) =>
            buildPage(child: const ChatBotView(), state: state),
      ),

      /// Accessibility
      GoRoute(
        path: '/accessibility',
        pageBuilder: (context, state) => buildPage(
          state: state,
          child: BlocProvider(
            create: (_) => getIt<RightstipsCubit>(),
            child: const AccessibilityHubView(),
          ),
        ),
      ),

      /// Login
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            fadePage(child: const LogInView(), state: state),
      ),

      /// Sign Up
      GoRoute(
        path: '/signUp',
        pageBuilder: (context, state) =>
            fadePage(child: const SignUpView(), state: state),
      ),

      /// Forgot Password
      GoRoute(
        path: '/forget',
        pageBuilder: (context, state) =>
            fadePage(child: const ForgotPasswordView(), state: state),
      ),

      /// Reset Password (مع email)
      GoRoute(
        path: '/resetPassword',
        pageBuilder: (context, state) {
          final email = state.extra as String;
          return fadePage(
            child: ResetPasswordView(email: email),
            state: state,
          );
        },
      ),

      /// 🔥 Bottom Navigation Shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavView(child: child);
        },
        routes: [

          /// Home
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                buildPage(child: const HomeView(), state: state),
          ),

          /// Institution
          GoRoute(
            path: '/institution',
            pageBuilder: (context, state) =>
                buildPage(child: const InstitutionView(), state: state),
          ),

          /// Reminders
          GoRoute(
            path: '/reminders',
            pageBuilder: (context, state) =>
                buildPage(child: const MedicalRemindersView(), state: state),
          ),

          /// Profile
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                buildPage(child: const ProfileView(), state: state),
          ),

          /// Community
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) =>
                buildPage(child: const CommunityView(), state: state),
          ),
        ],
      ),
    ],
  );
}