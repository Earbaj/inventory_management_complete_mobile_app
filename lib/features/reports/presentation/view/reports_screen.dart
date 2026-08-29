import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../branches/domain/entities/branch_entity.dart';
import '../../reports_models.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widget/invoice_logs_tab.dart';
import '../widget/items_sold_tab.dart';
import '../widget/reports_shimmer.dart';

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
  String? _selectedBranchId;
  List<BranchEntity> _branches = [];
  Timer? _searchDebounceTimer;
  bool _isFilterShow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBranches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportsBloc>().add(FetchReportsEvent(branchId: _selectedBranchId));
      }
    });
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

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query) {
    _searchDebounceTimer?.cancel();
    if (query.isEmpty) {
      context.read<ReportsBloc>().add(const SearchReportsEvent(''));
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ReportsBloc>().add(SearchReportsEvent(query));
      }
    });
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }

  void _applyDateFilter(BuildContext context, DateFilterType filter) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    if (filter == DateFilterType.today) {
      start = DateTime(now.year, now.month, now.day, 0, 0, 0);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    } else if (filter == DateFilterType.yesterday) {
      final yesterday = now.subtract(const Duration(days: 1));
      start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0);
      end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    } else if (filter == DateFilterType.last7Days) {
      final sevenDaysAgo = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 6));
      start = sevenDaysAgo;
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    } else if (filter == DateFilterType.last30Days) {
      final thirtyDaysAgo = DateTime(now.year, now.month, now.day, 0, 0, 0).subtract(const Duration(days: 29));
      start = thirtyDaysAgo;
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    } else if (filter == DateFilterType.custom) {
      _selectCustomDateRange(context);
      return;
    } else {
      // allTime
      start = null;
      end = null;
      setState(() {
        _selectedDateFilter = filter;
        _customDateRange = null;
      });
    }

    context.read<ReportsBloc>().add(FilterReportsByDateRangeEvent(
      startDate: start,
      endDate: end,
      branchId: _selectedBranchId,
      dateFilterType: filter,
    ));
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = _customDateRange ?? DateTimeRange(
      start: now.subtract(const Duration(days: 7)),
      end: now,
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
      initialDateRange: initialRange,
      helpText: 'Select Date Range for Reports',
      cancelText: 'Cancel',
      confirmText: 'Apply',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      final start = DateTime(pickedRange.start.year, pickedRange.start.month, pickedRange.start.day, 0, 0, 0);
      final end = DateTime(pickedRange.end.year, pickedRange.end.month, pickedRange.end.day, 23, 59, 59);

      setState(() {
        _selectedDateFilter = DateFilterType.custom;
        _customDateRange = pickedRange;
      });

      if (context.mounted) {
        context.read<ReportsBloc>().add(FilterReportsByDateRangeEvent(
          startDate: start,
          endDate: end,
          branchId: _selectedBranchId,
          dateFilterType: DateFilterType.custom,
        ));
      }
    }
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
              context.read<ReportsBloc>().add(FetchReportsEvent(
                searchQuery: _searchController.text,
                branchId: _selectedBranchId,
                forceRefresh: true,
              ));
            },
            tooltip: 'Refresh Reports',
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFilterShow = !_isFilterShow;
              });
            },
            tooltip: _isFilterShow ? 'Hide Filters' : 'Show Filters',
            icon: Icon(_isFilterShow ? Icons.filter_alt_off_rounded : Icons.filter_alt_rounded),
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
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, snapshot) {
          final state = snapshot;

          if (state is ReportsLoadingState && state is! ReportsLoadedState) {
            return const ReportsShimmerView();
          }

          if (state is ReportsErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 54),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<ReportsBloc>().add(FetchReportsEvent(
                          searchQuery: _searchController.text,
                          branchId: _selectedBranchId,
                          forceRefresh: true,
                        ));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final loadedState = state is ReportsLoadedState ? state : null;
          final summary = loadedState?.summary;
          final logs = loadedState?.filteredLogs ?? [];
          final isListLoading = loadedState?.isListLoading ?? false;

          return Column(
            children: [
              if (_isFilterShow) ...[
                // BRANCH FILTER DROPDOWN
                if (_branches.isNotEmpty)
                  BlocSelector<AuthBloc, AuthState, bool>(
                    selector: (state) =>
                    state is AuthenticatedState &&
                        (state.user?.role.toLowerCase() == 'admin' || state.user?.role.toLowerCase() == 'owner'),
                    builder: (context, isAdmin) {
                      if (!isAdmin) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                                context.read<ReportsBloc>().add(FetchReportsEvent(
                                  searchQuery: _searchController.text,
                                  branchId: branchId,
                                  forceRefresh: true,
                                ));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // DATE FILTER CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: DateFilterType.values.map((filter) {
                      final isSelected = _selectedDateFilter == filter;

                      String label = filter.label;
                      if (filter == DateFilterType.custom && _customDateRange != null) {
                        final s = _customDateRange!.start;
                        final e = _customDateRange!.end;
                        label = '${s.day} ${_getMonthName(s.month)} - ${e.day} ${_getMonthName(e.month)}';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: isSelected && isListLoading
                              ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected ? colorScheme.onPrimary : colorScheme.primary,
                              ),
                            ),
                          )
                              : (filter == DateFilterType.custom
                              ? Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                          )
                              : null),
                          label: Text(label),
                          selected: isSelected,
                          onSelected: isListLoading ? null : (_) => _applyDateFilter(context, filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // SEARCH INPUT
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _onSearchChanged(context, val),
                    decoration: InputDecoration(
                      hintText: 'Search invoice no or customer name...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: isListLoading && _searchController.text.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                          ),
                        ),
                      )
                          : (_searchController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(context, '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                          : null),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],

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

              const SizedBox(height: 6),

              // TAB VIEWS
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ReportsBloc>().add(FetchReportsEvent(
                      searchQuery: _searchController.text,
                      branchId: _selectedBranchId,
                      forceRefresh: true,
                    ));
                  },
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      isListLoading
                          ? const ReportsShimmerView(showMetricCards: false)
                          : InvoiceLogsTab(
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
                      isListLoading
                          ? const ReportsShimmerView(showMetricCards: false)
                          : ItemsSoldTab(
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
