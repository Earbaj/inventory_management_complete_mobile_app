import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/excel_export_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../../customer.dart';
import '../../customer_transaction.dart';
import '../widget/collect_payment_sheet.dart';
import '../widget/customer_statement_customer_header.dart';
import '../widget/customer_statement_summary_card.dart';
import '../widget/no_transaction_card.dart';
import '../widget/transaction_card.dart';

class CustomerStatementScreen extends StatefulWidget {
  final Customer customer;
  final List<CustomerTransaction> transactions;
  final List<SaleEntity> customerSales;

  const CustomerStatementScreen({
    super.key,
    required this.customer,
    required this.transactions,
    this.customerSales = const [],
  });

  @override
  State<CustomerStatementScreen> createState() => _CustomerStatementScreenState();
}

class _CustomerStatementScreenState extends State<CustomerStatementScreen> {
  bool _isLoading = true;
  double _totalSales = 0.0;
  double _totalPaid = 0.0;
  double _currentDue = 0.0;
  List<CustomerTransaction> _ledgerTransactions = [];
  List<SaleEntity> _ledgerSales = [];

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  double _calcFallbackSales() {
    if (widget.customerSales.isNotEmpty) {
      return widget.customerSales.fold(0.0, (sum, s) => sum + s.netTotal);
    }
    return widget.transactions
        .where((t) => t.type == TransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calcFallbackPaid() {
    if (widget.customerSales.isNotEmpty) {
      return widget.customerSales.fold(0.0, (sum, s) => sum + s.paidAmount);
    }
    return widget.transactions
        .where((t) => t.type == TransactionType.payment)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> _fetchLedger() async {
    setState(() => _isLoading = true);
    try {
      final data = await InjectionContainer.customerRemoteDataSource.getCustomerLedger(
        customerId: widget.customer.id,
      );

      final Map<String, dynamic> payload = data is Map<String, dynamic> ? data : {};
      final double sales = _parseDouble(payload['totalSales'] ?? payload['total_sales'] ?? payload['sales']);
      final double paid = _parseDouble(payload['totalPaid'] ?? payload['total_paid'] ?? payload['paid'] ?? payload['totalPayments']);
      final double due = _parseDouble(payload['totalDue'] ?? payload['total_due'] ?? payload['due'] ?? payload['closingBalance']).abs();

      final List rawLedger = payload['ledger'] ?? payload['transactions'] ?? payload['data'] ?? [];
      final List<CustomerTransaction> parsedTransactions = [];

      for (final item in rawLedger) {
        if (item is Map<String, dynamic>) {
          final typeStr = item['type']?.toString().toLowerCase() ?? 'sale';
          final TransactionType type = (typeStr == 'payment' || typeStr == 'due_payment' || typeStr == 'pay')
              ? TransactionType.payment
              : (typeStr == 'return' ? TransactionType.returnInvoice : TransactionType.sale);

          final double amount = _parseDouble(item['amount'] ?? item['debit'] ?? item['credit'] ?? item['netTotal']);
          final String ref = item['reference']?.toString() ?? item['invoiceNo']?.toString() ?? item['id']?.toString() ?? 'TRX';
          final DateTime date = DateTime.tryParse(item['date']?.toString() ?? item['createdAt']?.toString() ?? '') ?? DateTime.now();

          parsedTransactions.add(CustomerTransaction(
            id: item['id']?.toString() ?? UniqueKey().toString(),
            date: date,
            reference: ref,
            type: type,
            amount: amount.abs(),
            note: item['description']?.toString() ?? item['note']?.toString() ?? '',
          ));
        }
      }

      setState(() {
        _totalSales = sales > 0 ? sales : _calcFallbackSales();
        _totalPaid = paid > 0 ? paid : _calcFallbackPaid();
        _currentDue = due;
        if (parsedTransactions.isNotEmpty) {
          _ledgerTransactions = parsedTransactions;
        } else {
          _ledgerTransactions = widget.transactions;
        }
        _ledgerSales = widget.customerSales;
        _isLoading = false;
      });
    } catch (_) {
      // Fallback if API fails or offline
      setState(() {
        _totalSales = _calcFallbackSales();
        _totalPaid = _calcFallbackPaid();
        _currentDue = widget.customer.totalDue;
        _ledgerTransactions = widget.transactions;
        _ledgerSales = widget.customerSales;
        _isLoading = false;
      });
    }
  }

  void _exportPdf(BuildContext context) {
    final customerEntity = CustomerEntity(
      id: widget.customer.id,
      name: widget.customer.name,
      phone: widget.customer.phone,
      address: widget.customer.address,
      openingBalance: widget.customer.openingBalance,
      totalDue: _currentDue,
    );

    final htmlContent = PdfExportService.generateCustomerLedgerHtml(
      customer: customerEntity,
      customerSales: _ledgerSales,
      shopName: 'Smart Inventory Store',
      currencySymbol: '৳',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('PDF Customer Statement'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PDF Printable Statement generated successfully!'),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Text(
                  htmlContent,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer Statement PDF ready for printing!')),
              );
            },
            icon: const Icon(Icons.print_rounded),
            label: const Text('Print / Save PDF'),
          ),
        ],
      ),
    );
  }

  void _exportExcel(BuildContext context) {
    final customerEntity = CustomerEntity(
      id: widget.customer.id,
      name: widget.customer.name,
      phone: widget.customer.phone,
      address: widget.customer.address,
      openingBalance: widget.customer.openingBalance,
      totalDue: _currentDue,
    );

    final csvContent = ExcelExportService.generateCustomerLedgerCsv(
      customer: customerEntity,
      customerSales: _ledgerSales,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_chart_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Excel / CSV Export'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Excel CSV Statement exported successfully!'),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Text(
                  csvContent,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV Spreadsheet File exported!')),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download CSV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Statement'),
        actions: [
          IconButton(
            onPressed: _fetchLedger,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Ledger',
          ),
          IconButton(
            onPressed: () => _exportPdf(context),
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
            tooltip: 'Export PDF',
          ),
          IconButton(
            onPressed: () => _exportExcel(context),
            icon: const Icon(Icons.table_chart_rounded, color: Colors.green),
            tooltip: 'Export Excel CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                CustomerHeader(customer: widget.customer),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: [
                      Text('Current Balance', style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 5),
                      Text(
                        '৳ ${_currentDue.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentDue > 0 ? 'Due from customer' : 'No outstanding due',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (_currentDue > 0) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => CollectPaymentSheet(preSelectedCustomer: widget.customer),
                            ).then((_) => _fetchLedger());
                          },
                          icon: const Icon(Icons.payments_rounded, size: 18),
                          label: const Text('Receive Payment Collection'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: StatementSummaryCard(title: 'Opening', value: widget.customer.openingBalance)),
                    const SizedBox(width: 8),
                    Expanded(child: StatementSummaryCard(title: 'Sales', value: _totalSales)),
                    const SizedBox(width: 8),
                    Expanded(child: StatementSummaryCard(title: 'Paid', value: _totalPaid)),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Transactions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text('${_ledgerTransactions.length} records', style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 10),
                if (_ledgerTransactions.isEmpty)
                  NoTransactions()
                else
                  ..._ledgerTransactions.map((transaction) => TransactionCard(transaction: transaction)),
              ],
            ),
    );
  }
}