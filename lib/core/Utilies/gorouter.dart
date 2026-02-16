import 'package:go_router/go_router.dart';
import '../../Feature/Home/presentation/views/home_view.dart';
import '../../Feature/Splash/presentation/views/splash_view.dart';


class AppRouter {

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),

      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),

    ],
  );
}
