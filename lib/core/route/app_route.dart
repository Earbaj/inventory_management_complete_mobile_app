import 'package:go_router/go_router.dart';

import '../../main.dart';

class AppRoute {
  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    ],
  );
}


