import 'package:flutter/material.dart';
import '../../../../core/route/app_route.dart';
import '../../reports_models.dart';
import '../widget/invoice_logs_tab.dart';
import '../widget/items_sold_tab.dart';

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

  // Initial Demo Data
  late List<InvoiceLog> _allInvoices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initDemoData() {
    final now = DateTime.now();
    _allInvoices = [
      InvoiceLog(
        id: '1',
        invoiceNumber: 'INV-2026-001',
        date: now.subtract(const Duration(hours: 2)),
        customerName: 'Rahim Ahmed',
        customerPhone: '01712345678',
        totalAmount: 3400.0,
        paidAmount: 3400.0,
        dueAmount: 0.0,
        paymentStatus: PaymentStatus.paid,
        servedBy: 'Admin',
        items: const [
          ReportItemSold(
            itemId: 'ITEM-001',
            name: 'Wireless Mouse',
            category: 'Accessories',
            soldBy: 'Admin',
            unitPrice: 850.0,
            quantity: 2,
          ),
          ReportItemSold(
            itemId: 'ITEM-002',
            name: 'USB Keyboard',
            category: 'Accessories',
            soldBy: 'Admin',
            unitPrice: 1700.0,
            quantity: 1,
          ),
        ],
      ),
      InvoiceLog(
        id: '2',
        invoiceNumber: 'INV-2026-002',
        date: now.subtract(const Duration(hours: 18)),
        customerName: 'Karim Ullah',
        customerPhone: '01898765432',
        totalAmount: 14500.0,
        paidAmount: 10000.0,
        dueAmount: 4500.0,
        paymentStatus: PaymentStatus.partial,
        servedBy: 'Manager Dave',
        items: const [
          ReportItemSold(
            itemId: 'ITEM-003',
            name: 'HD Monitor 24"',
            category: 'Monitor',
            soldBy: 'Manager Dave',
            unitPrice: 14500.0,
            quantity: 1,
          ),
        ],
      ),
      InvoiceLog(
        id: '3',
        invoiceNumber: 'INV-2026-003',
        date: now.subtract(const Duration(days: 2)),
        customerName: 'Walk-in Customer',
        customerPhone: 'N/A',
        totalAmount: 900.0,
        paidAmount: 900.0,
        dueAmount: 0.0,
        paymentStatus: PaymentStatus.paid,
        servedBy: 'Sarah Staff',
        items: const [
          ReportItemSold(
            itemId: 'ITEM-006',
            name: 'USB-C Cable',
            category: 'Accessories',
            soldBy: 'Sarah Staff',
            unitPrice: 450.0,
            quantity: 2,
          ),
        ],
      ),
      InvoiceLog(
        id: '4',
        invoiceNumber: 'INV-2026-004',
        date: now.subtract(const Duration(days: 4)),
        customerName: 'Tanvir Hossain',
        customerPhone: '01911223344',
        totalAmount: 15600.0,
        paidAmount: 0.0,
        dueAmount: 15600.0,
        paymentStatus: PaymentStatus.unpaid,
        servedBy: 'Admin',
        items: const [
          ReportItemSold(
            itemId: 'ITEM-004',
            name: 'Office Chair',
            category: 'Furniture',
            soldBy: 'Admin',
            unitPrice: 7800.0,
            quantity: 2,
          ),
        ],
      ),
      InvoiceLog(
        id: '5',
        invoiceNumber: 'INV-2026-005',
        date: now.subtract(const Duration(days: 10)),
        customerName: 'Alim Rozario',
        customerPhone: '01655443322',
        totalAmount: 12400.0,
        paidAmount: 12400.0,
        dueAmount: 0.0,
        paymentStatus: PaymentStatus.paid,
        servedBy: 'Manager Dave',
        items: const [
          ReportItemSold(
            itemId: 'ITEM-005',
            name: 'External HDD 1TB',
            category: 'Storage',
            soldBy: 'Manager Dave',
            unitPrice: 6200.0,
            quantity: 2,
          ),
        ],
      ),
    ];
  }

  // Filter Invoices based on search query and selected date filter
  List<InvoiceLog> get _filteredInvoices {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    return _allInvoices.where((inv) {
      // 1. Search matching
      final matchesSearch = query.isEmpty ||
          inv.invoiceNumber.toLowerCase().contains(query) ||
          inv.customerName.toLowerCase().contains(query) ||
          inv.servedBy.toLowerCase().contains(query) ||
          inv.items.any((item) =>
              item.name.toLowerCase().contains(query) ||
              item.itemId.toLowerCase().contains(query));

      if (!matchesSearch) return false;

      // 2. Date Filter matching
      switch (_selectedDateFilter) {
        case DateFilterType.allTime:
          return true;
        case DateFilterType.today:
          return inv.date.year == now.year &&
              inv.date.month == now.month &&
              inv.date.day == now.day;
        case DateFilterType.yesterday:
          final yest = now.subtract(const Duration(days: 1));
          return inv.date.year == yest.year &&
              inv.date.month == yest.month &&
              inv.date.day == yest.day;
        case DateFilterType.last7Days:
          final limit = now.subtract(const Duration(days: 7));
          return inv.date.isAfter(limit);
        case DateFilterType.last30Days:
          final limit = now.subtract(const Duration(days: 30));
          return inv.date.isAfter(limit);
        case DateFilterType.custom:
          if (_customDateRange == null) return true;
          return inv.date.isAfter(_customDateRange!.start.subtract(const Duration(days: 1))) &&
              inv.date.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
      }
    }).toList();
  }

  // Aggregate items sold dynamically based on filtered invoices
  List<ReportItemSold> get _filteredItemsSold {
    final Map<String, ReportItemSold> aggregatedMap = {};

    for (final invoice in _filteredInvoices) {
      for (final item in invoice.items) {
        if (aggregatedMap.containsKey(item.itemId)) {
          final existing = aggregatedMap[item.itemId]!;
          aggregatedMap[item.itemId] = existing.copyWith(
            quantity: existing.quantity + item.quantity,
          );
        } else {
          aggregatedMap[item.itemId] = item;
        }
      }
    }

    final result = aggregatedMap.values.toList();
    result.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return result;
  }

  // Deleting invoice callback
  void _handleDeleteInvoice(InvoiceLog invoice) {
    setState(() {
      _allInvoices.removeWhere((inv) => inv.id == invoice.id);
    });
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 7)),
            end: DateTime.now(),
          ),
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedDateFilter = DateFilterType.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredInvoices = _filteredInvoices;
    final filteredItems = _filteredItemsSold;

    // Metrics calculations
    final totalRevenue = filteredInvoices.fold<double>(0, (sum, inv) => sum + inv.totalAmount);
    final totalDue = filteredInvoices.fold<double>(0, (sum, inv) => sum + inv.dueAmount);
    final totalItemsSoldQty = filteredItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Text('Sales & Sell Reports'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              icon: const Icon(Icons.receipt_long_rounded),
              text: 'Invoice Logs (${filteredInvoices.length})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_rounded),
              text: 'Items Sold (${filteredItems.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ===================================
          // SUMMARY METRICS CARDS
          // ===================================
          Container(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _MetricCard(
                    title: 'Total Revenue',
                    value: '৳${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  _MetricCard(
                    title: 'Invoices Count',
                    value: '${filteredInvoices.length}',
                    icon: Icons.receipt_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  _MetricCard(
                    title: 'Total Due',
                    value: '৳${totalDue.toStringAsFixed(0)}',
                    icon: Icons.pending_actions_rounded,
                    color: totalDue > 0 ? Colors.orange[800]! : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  _MetricCard(
                    title: 'Items Sold Qty',
                    value: '$totalItemsSoldQty Pcs',
                    icon: Icons.shopping_bag_rounded,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),

          // ===================================
          // SEARCH BAR & DATE FILTER
          // ===================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search invoice name, customer, item, served by...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Date Filters Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DateFilterType.values.map((filter) {
                      final isSelected = _selectedDateFilter == filter;
                      String label = filter.label;

                      if (filter == DateFilterType.custom &&
                          _customDateRange != null &&
                          isSelected) {
                        final s = _customDateRange!.start;
                        final e = _customDateRange!.end;
                        label = '${s.day}/${s.month} - ${e.day}/${e.month}';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: filter == DateFilterType.custom
                              ? const Icon(Icons.calendar_month_rounded, size: 16)
                              : null,
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (filter == DateFilterType.custom) {
                              _selectCustomDateRange();
                            } else {
                              setState(() {
                                _selectedDateFilter = filter;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // ===================================
          // TAB VIEWS (INVOICE LOGS & ITEMS SOLD)
          // ===================================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                InvoiceLogsTab(
                  invoices: filteredInvoices,
                  onDeleteInvoice: _handleDeleteInvoice,
                ),
                ItemsSoldTab(
                  itemsSold: filteredItems,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
