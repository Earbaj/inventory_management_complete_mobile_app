import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/reports/presentation/bloc/reports_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../widgets/profit_chart.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/sales_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_selling_items.dart';

import '../../../branches/domain/entities/branch_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  String selectedPeriod = 'This Month';
  String? _selectedBranchId;
  List<BranchEntity> _branches = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const FetchReportsEvent());
    context.read<InventoryBloc>().add(const FetchInventoryItemsEvent());
    context.read<CustomerBloc>().add(const FetchCustomersEvent());
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final list = await InjectionContainer.getBranchesUseCase();
      if (mounted) {
        setState(() {
          _branches = list;
        });
      }
    } catch (_) {}
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocSelector<AuthBloc, AuthState, bool>(
          selector: (state) {
            return state is AuthenticatedState &&
                state.user?.role.toLowerCase() == 'admin';
          },
        builder: (context, isAdmin) {
          return SafeArea(
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
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final userName = authState is AuthenticatedState ? (authState.user?.name ?? 'Owner') : 'Owner';
                              final shopName = authState is AuthenticatedState ? (authState.user?.shopName ?? 'Smart Inventory Store') : 'Smart Inventory Store';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getGreeting(),
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    userName,
                                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Event Dispatching via context
                            context.read<ReportsBloc>().add(FetchReportsEvent(branchId: _selectedBranchId));
                            context.read<InventoryBloc>().add(const FetchInventoryItemsEvent());
                            context.read<CustomerBloc>().add(const FetchCustomersEvent());
                          },
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                ),

                // ADMIN BRANCH FILTER DROPDOWN
                if (isAdmin && _branches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _selectedBranchId,
                            isExpanded: true,
                            hint: const Row(
                              children: [
                                Icon(Icons.store_rounded, size: 20, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('All Branches (Shop Aggregate)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.store_rounded, size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('All Branches (Shop Aggregate)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              ..._branches.map((b) {
                                return DropdownMenuItem<String?>(
                                  value: b.id,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.indigo),
                                      const SizedBox(width: 8),
                                      Text(b.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (branchId) {
                              setState(() {
                                _selectedBranchId = branchId;
                              });
                              context.read<ReportsBloc>().add(FetchReportsEvent(branchId: branchId));
                            },
                          ),
                        ),
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
                          if(isAdmin)...[
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
                      BlocBuilder<ReportsBloc,ReportsState>(
                        builder: (context, snapshot) {
                          final summary = snapshot is ReportsLoadedState ? snapshot.summary : null;
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
                      BlocBuilder<ReportsBloc,ReportsState>(
                        builder: (context, snapshot) {
                          final state = snapshot is ReportsLoadedState ? snapshot : InjectionContainer.reportsBloc.state;
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

                      // 3. Outstanding Dues (CustomerBloc / ReportsBloc)
                      BlocBuilder<CustomerBloc,CustomerState>(
                        builder: (context, snapshot) {
                          final custState = snapshot is CustomerLoadedState
                              ? snapshot
                              : InjectionContainer.customerBloc.state;

                          double due = 0.0;
                          if (custState is CustomerLoadedState && custState.customers.isNotEmpty) {
                            due = custState.customers.fold<double>(0.0, (sum, c) => sum + c.totalDue);
                          }

                          if (due == 0.0) {
                            final reportsState = InjectionContainer.reportsBloc.state;
                            if (reportsState is ReportsLoadedState && reportsState.summary != null) {
                              due = reportsState.summary!.totalDue > 0
                                  ? reportsState.summary!.totalDue
                                  : reportsState.summary!.dueRevenue;
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
                      BlocBuilder<InventoryBloc,InventoryState>(
                        builder: (context, snapshot) {
                          final state = snapshot is InventoryLoadedState ? snapshot : InjectionContainer.inventoryBloc.state;
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
                      BlocBuilder<CustomerBloc,CustomerState>(
                        builder: (context, snapshot) {
                          final state = snapshot is CustomerLoadedState ? snapshot : InjectionContainer.customerBloc.state;
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
                      BlocBuilder<InventoryBloc,InventoryState>(
                        builder: (context, snapshot) {
                          final state = snapshot is InventoryLoadedState ? snapshot : InjectionContainer.inventoryBloc.state;
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
                      children: [
                        SalesChart(),
                        if(isAdmin)...[
                          SizedBox(height: 16),
                          ProfitChart(),
                        ],

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
          );
        }
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