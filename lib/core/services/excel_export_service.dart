import 'dart:developer' as developer;
import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/customers/customer_transaction.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';

/// Excel & CSV Export Service for Customer Ledgers and Sales Data.
class ExcelExportService {
  /// Generates CSV Spreadsheet string for Customer Ledger Statements.
  static String generateCustomerLedgerCsv({
    required CustomerEntity customer,
    required List<CustomerTransaction> transactions,
  }) {
    developer.log('📊 [ExcelExportService] Exporting CSV Ledger for ${customer.name}', name: 'ExcelExportService');

    final buffer = StringBuffer();
    // Headers
    buffer.writeln('Customer Ledger Statement');
    buffer.writeln('Customer Name,"${customer.name}"');
    buffer.writeln('Phone,"${customer.phone}"');
    buffer.writeln('Opening Balance,${customer.openingBalance}');
    buffer.writeln('Total Outstanding Due,${customer.totalDue}');
    buffer.writeln('');
    buffer.writeln('Date,Reference,Description,Debit (+),Credit (-),Running Balance');

    final sortedTxs = List<CustomerTransaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Data rows
    for (final tx in sortedTxs) {
      final dateStr = '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}';

      final String desc;
      final double debit;
      final double credit;

      switch (tx.type) {
        case TransactionType.opening:
          desc = 'Opening Balance';
          debit = tx.amount;
          credit = 0.0;
          break;
        case TransactionType.sale:
          desc = 'Sale Invoice';
          debit = tx.amount;
          credit = 0.0;
          break;
        case TransactionType.payment:
          desc = tx.note.isNotEmpty ? 'Payment (${tx.note})' : 'Payment Received';
          debit = 0.0;
          credit = tx.amount;
          break;
        case TransactionType.returnInvoice:
          desc = tx.note.isNotEmpty ? 'Return (${tx.note})' : 'Product Return';
          debit = 0.0;
          credit = tx.amount;
          break;
      }

      final balStr = tx.runningBalance < 0
          ? '${tx.runningBalance.abs().toStringAsFixed(2)} (Due)'
          : (tx.runningBalance > 0 ? '${tx.runningBalance.toStringAsFixed(2)} (Credit)' : '0.00');

      buffer.writeln('$dateStr,"${tx.reference}","$desc",$debit,$credit,"$balStr"');
    }

    return buffer.toString();
  }

  /// Generates CSV Spreadsheet string for Sales Reports.
  static String generateSalesReportCsv(List<SaleEntity> sales) {
    developer.log('📊 [ExcelExportService] Exporting CSV Sales Report for ${sales.length} invoices', name: 'ExcelExportService');

    final buffer = StringBuffer();
    buffer.writeln('Sales & Revenue Log Statement');
    buffer.writeln('Total Invoices,${sales.length}');
    buffer.writeln('');
    buffer.writeln('Date,Invoice No,Customer,Gross Total,Discount,VAT,Net Total,Paid,Due,Payment Method');

    for (final sale in sales) {
      final dateStr = '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
      final customerName = sale.customer?.name ?? 'Walk-in Customer';
      buffer.writeln('$dateStr,"${sale.invoiceNo}","$customerName",${sale.subtotal},${sale.discountAmount},${sale.vatAmount},${sale.netTotal},${sale.paidAmount},${sale.dueAmount},"${sale.paymentMethod}"');
    }

    return buffer.toString();
  }
}
