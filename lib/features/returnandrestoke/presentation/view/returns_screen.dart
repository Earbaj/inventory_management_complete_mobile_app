import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/route/app_route.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../posbilling/domain/entities/cart_item_entity.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../domain/entities/return_item_entity.dart';
import '../bloc/returns_event.dart';
import '../bloc/returns_state.dart';

class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  CustomerEntity? _selectedCustomer;
  SaleEntity? _selectedInvoice;
  final Map<String, int> _returnQuantities = {};
  String _refundMethod = 'cash';
  bool _isRestocked = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Dispatch initial fetch events
    InjectionContainer.returnsBloc.add(const FetchReturnLogsEvent());
    InjectionContainer.customerBloc.add(const FetchCustomersEvent());
    InjectionContainer.reportsBloc.add(const FetchReportsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    InjectionContainer.returnsBloc.add(FetchReturnLogsEvent(query));
  }

  void _onCustomerSelected(CustomerEntity? customer) {
    setState(() {
      _selectedCustomer = customer;
      _selectedInvoice = null;
      _returnQuantities.clear();
    });
  }

  void _onInvoiceSelected(SaleEntity? invoice) {
    setState(() {
      _selectedInvoice = invoice;
      _returnQuantities.clear();
      if (invoice != null) {
        for (final item in invoice.items) {
          _returnQuantities[item.item.id] = 0;
        }
      }
    });
  }

  void _updateReturnQuantity(String itemId, int maxQty, int delta) {
    final current = _returnQuantities[itemId] ?? 0;
    final newQty = (current + delta).clamp(0, maxQty);
    setState(() {
      _returnQuantities[itemId] = newQty;
    });
  }

  double get _calculatedRefundTotal {
    if (_selectedInvoice == null) return 0.0;
    double total = 0.0;
    for (final item in _selectedInvoice!.items) {
      final qty = _returnQuantities[item.item.id] ?? 0;
      total += qty * item.item.retailSellPrice;
    }
    return total;
  }

  int get _totalReturnItemsCount {
    return _returnQuantities.values.fold(0, (sum, q) => sum + q);
  }

  Future<void> _submitProductReturn() async {
    if (_selectedInvoice == null || _totalReturnItemsCount == 0) return;

    setState(() => _isSubmitting = true);

    try {
      int processedCount = 0;
      for (final item in _selectedInvoice!.items) {
        final qty = _returnQuantities[item.item.id] ?? 0;
        if (qty > 0) {
          final returnItem = ReturnItemEntity(
            id: '',
            invoiceNo: _selectedInvoice!.invoiceNo,
            itemId: item.item.id,
            itemName: item.item.name,
            customerName: _selectedCustomer?.name ?? _selectedInvoice!.customer?.name ?? 'Walk-in Customer',
            returnQuantity: qty,
            unitPrice: item.item.retailSellPrice,
            totalRefundAmount: qty * item.item.retailSellPrice,
            refundMethod: _refundMethod,
            isRestocked: _isRestocked,
            reason: reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'Customer Return',
            createdAt: DateTime.now(),
          );

          InjectionContainer.returnsBloc.add(ProcessReturnItemEvent(returnItem));
          processedCount++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully processed return for $processedCount item(s) & restocked inventory!'),
          backgroundColor: Colors.green[700],
        ),
      );

      setState(() {
        _selectedInvoice = null;
        _returnQuantities.clear();
        reasonController.clear();
        _isSubmitting = false;
      });

      _tabController.animateTo(1); // Switch to Return History tab
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process return: $e'), backgroundColor: Colors.red),
      );
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
        title: const Text('Returns & Restock'),
        actions: [
          IconButton(
            onPressed: () {
              InjectionContainer.returnsBloc.add(const FetchReturnLogsEvent());
              InjectionContainer.customerBloc.add(const FetchCustomersEvent());
              InjectionContainer.reportsBloc.add(const FetchReportsEvent());
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.restore_rounded), text: 'Process Return'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Return History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProcessReturnTab(context, theme, colorScheme),
          _buildHistoryTab(context, theme, colorScheme),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: PROCESS RETURN & RESTOCK WORKFLOW
  // ==========================================
  Widget _buildProcessReturnTab(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    // 1. Fetch Customers List
    final custSnapshot = InjectionContainer.customerBloc.state;
    final List<CustomerEntity> customerList = custSnapshot is CustomerLoadedState ? custSnapshot.customers : [];

    // 2. Fetch Sales Invoices List
    final reportsSnapshot = InjectionContainer.reportsBloc.state;
    final List<SaleEntity> allInvoices = reportsSnapshot is ReportsLoadedState ? reportsSnapshot.invoiceLogs : [];

    // Filter invoices by selected customer
    final List<SaleEntity> filteredInvoices = allInvoices.where((sale) {
      if (_selectedCustomer == null) return true;
      final matchId = sale.customer?.id.isNotEmpty == true && sale.customer!.id == _selectedCustomer!.id;
      final matchName = sale.customer?.name.isNotEmpty == true &&
          sale.customer!.name.trim().toLowerCase() == _selectedCustomer!.name.trim().toLowerCase();
      final matchPhone = sale.customer?.phone.isNotEmpty == true &&
          _selectedCustomer!.phone.isNotEmpty &&
          sale.customer!.phone.trim() == _selectedCustomer!.phone.trim();
      return matchId || matchName || matchPhone;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // STEP 1: CUSTOMER SELECTION DROPDOWN
        const Text(
          '1. Select Customer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CustomerEntity?>(
          value: _selectedCustomer,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'All Invoices / Walk-in Customer',
            prefixIcon: const Icon(Icons.person_search_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
          items: [
            const DropdownMenuItem<CustomerEntity?>(
              value: null,
              child: Text('All Customers & Walk-in Invoices', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ...customerList.map((customer) {
              return DropdownMenuItem<CustomerEntity?>(
                value: customer,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      'Phone: ${customer.phone}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: _onCustomerSelected,
        ),

        const SizedBox(height: 20),

        // STEP 2: INVOICE SELECTION DROPDOWN
        const Text(
          '2. Select Invoice to Return Items From',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SaleEntity?>(
          value: _selectedInvoice,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: filteredInvoices.isEmpty ? 'No invoices found for this customer' : 'Choose an invoice',
            prefixIcon: const Icon(Icons.receipt_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
          ),
          items: filteredInvoices.map((invoice) {
            final dateStr = '${invoice.createdAt.day}/${invoice.createdAt.month}/${invoice.createdAt.year}';
            return DropdownMenuItem<SaleEntity?>(
              value: invoice,
              child: Row(
                children: [
                  Text(
                    invoice.invoiceNo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text('($dateStr)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  Text(
                    '৳${invoice.netTotal.toStringAsFixed(0)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _onInvoiceSelected,
        ),

        const SizedBox(height: 20),

        // STEP 3: ITEM DETAILS & RETURN QUANTITY EDITING
        if (_selectedInvoice != null) ...[
          // INVOICE SUMMARY HEADER CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Invoice: ${_selectedInvoice!.invoiceNo}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Paid: ৳${_selectedInvoice!.paidAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer: ${_selectedInvoice!.customer?.name ?? "Walk-in Customer"} | Items: ${_selectedInvoice!.items.length}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Text(
            '3. Select Return Quantity for Purchased Items',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),

          // INVOICE ITEMS LIST WITH QUANTITY CONTROLS
          ..._selectedInvoice!.items.map((cartItem) {
            final itemId = cartItem.item.id;
            final purchasedQty = cartItem.quantity;
            final currentReturnQty = _returnQuantities[itemId] ?? 0;
            final itemSubtotal = currentReturnQty * cartItem.item.retailSellPrice;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: currentReturnQty > 0
                      ? colorScheme.primary
                      : theme.dividerColor.withValues(alpha: 0.5),
                  width: currentReturnQty > 0 ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem.item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Price: ৳${cartItem.item.retailSellPrice.toStringAsFixed(0)} | Purchased: $purchasedQty',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (currentReturnQty > 0)
                        Text(
                          'Refund: ৳${itemSubtotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 16),

                  // STEPPER CONTROL FOR RETURN QUANTITY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Return Quantity:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: currentReturnQty > 0
                                ? () => _updateReturnQuantity(itemId, purchasedQty, -1)
                                : null,
                            icon: const Icon(Icons.remove, size: 18),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              '$currentReturnQty / $purchasedQty',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: currentReturnQty < purchasedQty
                                ? () => _updateReturnQuantity(itemId, purchasedQty, 1)
                                : null,
                            icon: const Icon(Icons.add, size: 18),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // STEP 4: RETURN SUMMARY & SUBMISSION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Return Items:', style: TextStyle(fontSize: 14)),
                    Text('$_totalReturnItemsCount units', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Refund Amount:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(
                      '৳${_calculatedRefundTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // RESTOCK INVENTORY SWITCH
                SwitchListTile(
                  title: const Text('Restock Product(s) back into Inventory'),
                  subtitle: const Text('Increases available stock in warehouse'),
                  value: _isRestocked,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isRestocked = val),
                ),

                const SizedBox(height: 10),

                // REFUND METHOD
                const Text('Refund Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Cash'),
                        selected: _refundMethod == 'cash',
                        onSelected: (sel) {
                          if (sel) setState(() => _refundMethod = 'cash');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Due Adjust'),
                        selected: _refundMethod == 'due_adjust',
                        onSelected: (sel) {
                          if (sel) setState(() => _refundMethod = 'due_adjust');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('bKash'),
                        selected: _refundMethod == 'bkash',
                        onSelected: (sel) {
                          if (sel) setState(() => _refundMethod = 'bkash');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // REASON / NOTE
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Reason for return (e.g. Damaged, Wrong size)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                ),

                const SizedBox(height: 18),

                // SUBMIT BUTTON
                FilledButton.icon(
                  onPressed: _totalReturnItemsCount == 0 || _isSubmitting ? null : _submitProductReturn,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(
                    _isSubmitting
                        ? 'Processing Return...'
                        : 'Submit Return & Restock (৳${_calculatedRefundTotal.toStringAsFixed(0)})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ] else
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Please select a customer and an invoice to process product return.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // TAB 2: RETURN TRANSACTION HISTORY LOGS
  // ==========================================
  Widget _buildHistoryTab(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return StreamBuilder<ReturnsState>(
      stream: InjectionContainer.returnsBloc.stream,
      initialData: InjectionContainer.returnsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state is ReturnsLoadingState && state is! ReturnsLoadedState) {
          return const Center(child: CircularProgressIndicator());
        }

        final loadedState = state is ReturnsLoadedState ? state : null;
        final returnLogs = loadedState?.filteredLogs ?? [];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search return logs by invoice or item name',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            _onSearchChanged('');
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

            if (returnLogs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No return logs found.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: returnLogs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = returnLogs[index];
                  final dateStr = '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}';

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.invoiceNo,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Refund: ৳${item.totalRefundAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Item: ${item.itemName} (Qty: ${item.returnQuantity})',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer: ${item.customerName ?? "Walk-in"}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(dateStr, style: theme.textTheme.bodySmall),
                          ],
                        ),
                        if (item.reason != null && item.reason!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reason: ${item.reason}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}