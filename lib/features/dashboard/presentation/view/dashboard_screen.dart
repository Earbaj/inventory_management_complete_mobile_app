import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../widgets/profit_chart.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/sales_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_selling_items.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  String selectedPeriod = 'This Month';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch events to all BLoC instances
    InjectionContainer.reportsBloc.add(const FetchReportsEvent());
    InjectionContainer.inventoryBloc.add(const FetchInventoryItemsEvent());
    InjectionContainer.customerBloc.add(const FetchCustomersEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER WITH SHOP & USER PROFILE
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        AppRoute.shellScaffoldKey.currentState?.openDrawer();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                      ),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StreamBuilder<AuthState>(
                        stream: InjectionContainer.authBloc.stream,
                        initialData: InjectionContainer.authBloc.state,
                        builder: (context, snapshot) {
                          final authState = snapshot.data;
                          final userName = authState is AuthenticatedState ? (authState.user?.name ?? 'Owner') : 'Owner';
                          final shopName = authState is AuthenticatedState ? (authState.user?.shopName ?? 'Smart Inventory Store') : 'Smart Inventory Store';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Day, $userName 👋',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                shopName,
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        InjectionContainer.reportsBloc.add(const FetchReportsEvent());
                        InjectionContainer.inventoryBloc.add(const FetchInventoryItemsEvent());
                        InjectionContainer.customerBloc.add(const FetchCustomersEvent());
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
            ),

            // QUICK NAVIGATION ACTIONS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.point_of_sale_rounded,
                        label: 'POS Billing',
                        color: colorScheme.primary,
                        onTap: () {
                          AppRoute.shellScaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.add_shopping_cart_rounded,
                        label: 'Add Item',
                        color: Colors.teal,
                        onTap: () {
                          AppRoute.shellScaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'Customers',
                        color: Colors.orange,
                        onTap: () {
                          AppRoute.shellScaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.bar_chart_rounded,
                        label: 'Reports',
                        color: Colors.purple,
                        onTap: () {
                          AppRoute.shellScaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // STAT CARDS LIST GRID
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  // 1. Total Sell Revenue (ReportsBloc)
                  StreamBuilder<ReportsState>(
                    stream: InjectionContainer.reportsBloc.stream,
                    initialData: InjectionContainer.reportsBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
                      final summary = state is ReportsLoadedState ? state.summary : null;
                      final revenue = summary != null ? summary.totalRevenue : 0.0;

                      return StatCard(
                        title: 'Total Sell',
                        value: '৳ ${revenue.toStringAsFixed(0)}',
                        icon: Icons.shopping_bag_outlined,
                        iconBackground: const Color(0xFFE8F0FF),
                        iconColor: const Color(0xFF2563EB),
                        percentage: 'Active',
                        isPositive: true,
                      );
                    },
                  ),

                  // 2. Total Invoices Count (ReportsBloc)
                  StreamBuilder<ReportsState>(
                    stream: InjectionContainer.reportsBloc.stream,
                    initialData: InjectionContainer.reportsBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
                      final summary = state is ReportsLoadedState ? state.summary : null;
                      final salesCount = summary != null ? summary.totalSalesCount : 0;

                      return StatCard(
                        title: 'Total Invoices',
                        value: '$salesCount',
                        icon: Icons.receipt_rounded,
                        iconBackground: const Color(0xFFE7F9EF),
                        iconColor: const Color(0xFF10B981),
                        percentage: 'Count',
                        isPositive: true,
                      );
                    },
                  ),

                  // 3. Outstanding Dues (ReportsBloc / CustomerBloc)
                  StreamBuilder<ReportsState>(
                    stream: InjectionContainer.reportsBloc.stream,
                    initialData: InjectionContainer.reportsBloc.state,
                    builder: (context, snapshot) {
                      final reportsState = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
                      final summary = reportsState is ReportsLoadedState ? reportsState.summary : null;
                      final logs = reportsState is ReportsLoadedState ? reportsState.invoiceLogs : null;

                      double due = summary != null ? (summary.totalDue > 0 ? summary.totalDue : summary.dueRevenue) : 0.0;

                      if (due == 0.0 && logs != null && logs.isNotEmpty) {
                        due = logs.fold<double>(0.0, (sum, s) => sum + s.dueAmount);
                      }

                      if (due == 0.0) {
                        final customerState = InjectionContainer.customerBloc.state;
                        if (customerState is CustomerLoadedState) {
                          due = customerState.customers.fold<double>(0.0, (sum, c) => sum + c.totalDue);
                        }
                      }

                      return StatCard(
                        title: 'Outstanding Due',
                        value: '৳ ${due.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet_outlined,
                        iconBackground: const Color(0xFFFFF2E5),
                        iconColor: const Color(0xFFF97316),
                        percentage: 'Due',
                        isPositive: false,
                      );
                    },
                  ),

                  // 4. Low Stock Alert Count (InventoryBloc)
                  StreamBuilder<InventoryState>(
                    stream: InjectionContainer.inventoryBloc.stream,
                    initialData: InjectionContainer.inventoryBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data is InventoryLoadedState ? snapshot.data : InjectionContainer.inventoryBloc.state;
                      final lowStockCount = state is InventoryLoadedState
                          ? state.items.where((i) => i.isLowStock || i.isOutOfStock).length
                          : 0;

                      return StatCard(
                        title: 'Low Stock Alert',
                        value: '$lowStockCount',
                        icon: Icons.warning_amber_rounded,
                        iconBackground: const Color(0xFFFFE9EC),
                        iconColor: const Color(0xFFEF4444),
                        subtitle: 'Items need restock',
                      );
                    },
                  ),

                  // 5. Total Active Customers (CustomerBloc)
                  StreamBuilder<CustomerState>(
                    stream: InjectionContainer.customerBloc.stream,
                    initialData: InjectionContainer.customerBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data is CustomerLoadedState ? snapshot.data : InjectionContainer.customerBloc.state;
                      final customerCount = state is CustomerLoadedState ? state.customers.length : 0;

                      return StatCard(
                        title: 'Total Customers',
                        value: '$customerCount',
                        icon: Icons.group_outlined,
                        iconBackground: const Color(0xFFF0E9FF),
                        iconColor: const Color(0xFF8B5CF6),
                        percentage: 'Active',
                        isPositive: true,
                      );
                    },
                  ),

                  // 6. Total Items Count (InventoryBloc)
                  StreamBuilder<InventoryState>(
                    stream: InjectionContainer.inventoryBloc.stream,
                    initialData: InjectionContainer.inventoryBloc.state,
                    builder: (context, snapshot) {
                      final state = snapshot.data is InventoryLoadedState ? snapshot.data : InjectionContainer.inventoryBloc.state;
                      final totalItems = state is InventoryLoadedState ? state.items.length : 0;

                      return StatCard(
                        title: 'Inventory Items',
                        value: '$totalItems',
                        icon: Icons.inventory_2_outlined,
                        iconBackground: const Color(0xFFE7F8F5),
                        iconColor: const Color(0xFF14B8A6),
                        percentage: 'Items',
                        isPositive: true,
                      );
                    },
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.28,
                ),
              ),
            ),

            // CHARTS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  children: const [
                    SalesChart(),
                    SizedBox(height: 16),
                    ProfitChart(),
                  ],
                ),
              ),
            ),

            // TOP SELLING ITEMS
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: TopSellingItems(),
              ),
            ),

            // RECENT TRANSACTIONS
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: RecentTransactions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}