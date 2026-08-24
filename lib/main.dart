import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/branches/presentation/bloc/branch_bloc.dart';
import 'package:inventory_management_complete/features/branches/presentation/bloc/branch_event.dart';
import 'package:inventory_management_complete/features/posbilling/presentation/bloc/pos_bloc.dart';
import 'package:inventory_management_complete/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:inventory_management_complete/features/staff_managers/presentation/bloc/staff_bloc.dart';
import 'package:inventory_management_complete/features/recycle_bin/presentation/bloc/recycle_bin_bloc.dart';
import 'package:inventory_management_complete/features/recycle_bin/presentation/bloc/recycle_bin_event.dart';

import 'package:inventory_management_complete/features/expenses/presentation/bloc/expenses_bloc.dart';
import 'package:inventory_management_complete/features/expenses/presentation/bloc/expenses_event.dart';

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
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
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
        BlocProvider<PosBloc>(
          create: (context) => InjectionContainer.posBloc,
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => InjectionContainer.settingsBloc..add(const FetchSettingsEvent()),
        ),
        BlocProvider<RecycleBinBloc>(
          create: (context) => InjectionContainer.recycleBinBloc..add(const FetchTrashItemsEvent()),
        ),
        BlocProvider<BranchBloc>(
          create: (context) => InjectionContainer.branchBloc..add(const FetchBranchesEvent()),
        ),
        BlocProvider<ExpensesBloc>(
          create: (context) => InjectionContainer.expensesBloc..add(const FetchExpensesEvent()),
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

