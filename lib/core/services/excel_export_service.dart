import 'dart:developer' as developer;
import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';

/// Excel & CSV Export Service for Customer Ledgers and Sales Data.
class ExcelExportService {
  /// Generates CSV Spreadsheet string for Customer Ledger Statements.
  static String generateCustomerLedgerCsv({
    required CustomerEntity customer,
    required List<SaleEntity> customerSales,
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
    buffer.writeln('Date,Invoice No,Total Amount,Paid Amount,Due Amount,Payment Method');

    // Data rows
    for (final sale in customerSales) {
      final dateStr = '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
      buffer.writeln('$dateStr,"${sale.invoiceNo}",${sale.netTotal},${sale.paidAmount},${sale.dueAmount},"${sale.paymentMethod}"');
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
