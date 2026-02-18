import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/bottom_nav_bar.dart';
import '../../Feature/institution.dart';
import '../../Feature/medical_reminders.dart';
import '../../Feature/profile.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [

      /// Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
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
        ],
      ),
    ],
  );
}
