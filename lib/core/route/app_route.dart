import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/view/login_screen.dart';
import '../../features/auth/presentation/view/register_screen.dart';
import '../../features/splash/presentation/view/splash_screen.dart';

class AppRoute {
  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',

    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
    ],
  );
}


