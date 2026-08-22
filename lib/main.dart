import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:inventory_management_complete/features/staff_managers/presentation/bloc/staff_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/route/app_route.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/customer_event.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_event.dart';
import 'features/reports/presentation/bloc/reports_event.dart';
import 'features/staff_managers/presentation/bloc/staff_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InjectionContainer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => InjectionContainer.authBloc..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<ReportsBloc>(
          create: (context) => InjectionContainer.reportsBloc..add(const FetchReportsEvent()),
        ),
        BlocProvider<InventoryBloc>(
          create: (context) => InjectionContainer.inventoryBloc..add(const FetchInventoryItemsEvent()),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) => InjectionContainer.customerBloc..add(const FetchCustomersEvent()),
        ),
        BlocProvider<StaffBloc>(
          create: (context) => InjectionContainer.staffBloc..add(const FetchStaffEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
      
        themeMode: ThemeMode.system,
        routerConfig: AppRoute.router,
      ),
    );
  }
}

