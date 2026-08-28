import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_complete/features/reports/presentation/bloc/reports_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widget/invoice_logs_tab.dart';
import '../widget/items_sold_tab.dart';
import '../../reports_models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  DateFilterType _selectedDateFilter = DateFilterType.allTime;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Dispatch initial fetch to ReportsBloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportsBloc>().add(const FetchReportsEvent());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query) {
    context.read<ReportsBloc>().add(FetchReportsEvent(searchQuery: query));
  }

  void _applyDateFilter(BuildContext context, DateFilterType filter) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (filter == DateFilterType.today) {
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (filter == DateFilterType.last7Days) {
      start = now.subtract(Duration(days: now.weekday - 1));
      end = now;
    } else if (filter == DateFilterType.last30Days) {
      start = DateTime(now.year, now.month, 1);
      end = now;
    }

    setState(() {
      _selectedDateFilter = filter;
      _customDateRange = null;
    });

    context.read<ReportsBloc>().add(FilterReportsByDateRangeEvent(
      startDate: start,
      endDate: end,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text('Sales Reports & Analytics'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ReportsBloc>().add(FetchReportsEvent(searchQuery: _searchController.text));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Invoice Logs', icon: Icon(Icons.receipt_long_rounded)),
            Tab(text: 'Items Sold', icon: Icon(Icons.inventory_2_outlined)),
          ],
        ),
      ),
      body: BlocBuilder<ReportsBloc,ReportsState>(
        builder: (context, snapshot) {
          final state = snapshot;

          if (state is ReportsLoadingState && state is! ReportsLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportsErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReportsBloc>().add(FetchReportsEvent(searchQuery: _searchController.text));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state is ReportsLoadedState ? state : null;
          final summary = loadedState?.summary;
          final logs = loadedState?.filteredLogs ?? [];

          return Column(
            children: [
              // DATE FILTER CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: DateFilterType.values.map((filter) {
                    final isSelected = _selectedDateFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter.label),
                        selected: isSelected,
                        onSelected: (_) => _applyDateFilter(context, filter),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // SUMMARY METRICS CARDS
              if (summary != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildMetricCard(
                        title: 'Gross Revenue',
                        value: '৳${summary.totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        title: 'Total Invoices',
                        value: '${summary.totalSalesCount}',
                        icon: Icons.receipt_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildMetricCard(
                        title: 'Total Dues',
                        value: '৳${summary.totalDue.toStringAsFixed(0)}',
                        icon: Icons.money_off_rounded,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),

              // SEARCH INPUT
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _onSearchChanged(context, val),
                  decoration: InputDecoration(
                    hintText: 'Search invoice no or customer name',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged(context, '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // TAB VIEWS
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    InvoiceLogsTab(
                      invoices: logs.map((sale) {
                        return InvoiceLog(
                          id: sale.id,
                          invoiceNumber: sale.invoiceNo,
                          date: sale.createdAt,
                          customerName: sale.customer?.name ?? 'Walk-in Customer',
                          customerPhone: sale.customer?.phone ?? 'N/A',
                          totalAmount: sale.netTotal,
                          paidAmount: sale.paidAmount,
                          dueAmount: sale.dueAmount,
                          paymentStatus: sale.dueAmount > 0 ? PaymentStatus.partial : PaymentStatus.paid,
                          servedBy: sale.servedBy,
                          items: sale.items.map((cartItem) {
                            return ReportItemSold(
                              itemId: cartItem.item.id,
                              name: cartItem.item.name,
                              category: cartItem.item.category,
                              soldBy: sale.servedBy,
                              unitPrice: cartItem.item.retailSellPrice,
                              quantity: cartItem.quantity,
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                    ItemsSoldTab(
                      invoices: logs.map((sale) {
                        return InvoiceLog(
                          id: sale.id,
                          invoiceNumber: sale.invoiceNo,
                          date: sale.createdAt,
                          customerName: sale.customer?.name ?? 'Walk-in Customer',
                          customerPhone: sale.customer?.phone ?? 'N/A',
                          totalAmount: sale.netTotal,
                          paidAmount: sale.paidAmount,
                          dueAmount: sale.dueAmount,
                          paymentStatus: sale.dueAmount > 0 ? PaymentStatus.partial : PaymentStatus.paid,
                          servedBy: sale.servedBy,
                          items: sale.items.map((cartItem) {
                            return ReportItemSold(
                              itemId: cartItem.item.id,
                              name: cartItem.item.name,
                              category: cartItem.item.category,
                              soldBy: sale.servedBy,
                              unitPrice: cartItem.item.retailSellPrice,
                              quantity: cartItem.quantity,
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
