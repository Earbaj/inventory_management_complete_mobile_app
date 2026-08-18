import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/view/login_screen.dart';
import '../../features/auth/presentation/view/register_screen.dart';
import '../../features/auth/presentation/view/forgot_password_screen.dart';
import '../../features/auth/presentation/view/reset_password_screen.dart';
import '../../features/customers/presentation/view/customers_screen.dart';
import '../../features/dashboard/presentation/view/dashboard_screen.dart';
import '../../features/inventory/presentation/view/inventory_screen.dart';
import '../../features/posbilling/presentation/view/pos_billing_screen.dart';
import '../../features/returnandrestoke/presentation/view/returns_screen.dart';
import '../../features/recycle_bin/presentation/view/recycle_bin_screen.dart';
import '../../features/reports/presentation/view/reports_screen.dart';
import '../../features/settings/presentation/view/settings_screen.dart';
import '../../features/staff_managers/presentation/view/staff_managers_screen.dart';
import '../../features/super_admin/presentation/view/super_admin_screen.dart';
import '../../features/splash/presentation/view/splash_screen.dart';
import '../../features/dashboard/presentation/widgets/app_drawer.dart';

class AppRoute {
  static final GlobalKey<ScaffoldState> shellScaffoldKey = GlobalKey<ScaffoldState>();

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

      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),

      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final email = state.extra as String?;
          return ResetPasswordScreen(email: email);
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          final currentRoute = state.uri.path;
          return Scaffold(
            key: shellScaffoldKey,
            drawer: AppDrawer(currentRoute: currentRoute),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) {
              return const DashboardScreen();
            },
          ),

          GoRoute(
            path: '/pos-billing',
            builder: (context, state) {
              return const PosBillingScreen();
            },
          ),

          GoRoute(
            path: '/inventory',
            builder: (context, state) {
              return InventoryScreen();
            },
          ),

          GoRoute(
            path: '/customers',
            builder: (context, state) {
              return CustomersScreen();
            },
          ),

          GoRoute(
            path: '/returns',
            builder: (context, state) {
              return ReturnsScreen();
            },
          ),

          GoRoute(
            path: '/reports',
            builder: (context, state) {
              return const ReportsScreen();
            },
          ),

          GoRoute(
            path: '/staff-managers',
            builder: (context, state) {
              return const StaffManagersScreen();
            },
          ),

          GoRoute(
            path: '/recycle-bin',
            builder: (context, state) {
              return const RecycleBinScreen();
            },
          ),

          GoRoute(
            path: '/settings',
            builder: (context, state) {
              return const SettingsScreen();
            },
          ),

          GoRoute(
            path: '/super-admin',
            builder: (context, state) {
              return const SuperAdminScreen();
            },
          ),
        ],
      ),
    ],
  );
}
