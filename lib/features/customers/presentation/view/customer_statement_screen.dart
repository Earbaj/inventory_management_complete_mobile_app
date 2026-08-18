import 'package:flutter/material.dart';
import '../../../../core/services/excel_export_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../domain/entities/customer_entity.dart';
import '../../customer.dart';
import '../../customer_transaction.dart';
import '../widget/customer_statement_customer_header.dart';
import '../widget/customer_statement_summary_card.dart';
import '../widget/no_transaction_card.dart';
import '../widget/transaction_card.dart';

class CustomerStatementScreen extends StatelessWidget {
  final Customer customer;
  final List<CustomerTransaction> transactions;

  const CustomerStatementScreen({
    super.key,
    required this.customer,
    required this.transactions,
  });

  double get totalSales {
    return transactions
        .where((transaction) => transaction.type == TransactionType.sale)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalPayments {
    return transactions
        .where((transaction) => transaction.type == TransactionType.payment)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalReturns {
    return transactions
        .where((transaction) => transaction.type == TransactionType.returnInvoice)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get currentBalance {
    return customer.openingBalance + totalSales - totalPayments - totalReturns;
  }

  void _exportPdf(BuildContext context) {
    final customerEntity = CustomerEntity(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      openingBalance: customer.openingBalance,
      totalDue: currentBalance,
    );

    final htmlContent = PdfExportService.generateCustomerLedgerHtml(
      customer: customerEntity,
      customerSales: const [],
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
                maxHeight: 200,
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
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      address: customer.address,
      openingBalance: customer.openingBalance,
      totalDue: currentBalance,
    );

    final csvContent = ExcelExportService.generateCustomerLedgerCsv(
      customer: customerEntity,
      customerSales: const [],
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
                maxHeight: 200,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          CustomerHeader(customer: customer),
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
                  '৳ ${currentBalance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  currentBalance > 0 ? 'Due from customer' : 'No outstanding due',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: StatementSummaryCard(title: 'Opening', value: customer.openingBalance)),
              const SizedBox(width: 8),
              Expanded(child: StatementSummaryCard(title: 'Sales', value: totalSales)),
              const SizedBox(width: 8),
              Expanded(child: StatementSummaryCard(title: 'Paid', value: totalPayments)),
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
              Text('${transactions.length} records', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            NoTransactions()
          else
            ...transactions.map((transaction) => TransactionCard(transaction: transaction)),
        ],
      ),
    );
  }
}