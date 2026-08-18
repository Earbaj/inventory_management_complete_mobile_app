import 'dart:developer' as developer;
import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';

/// PDF Export & Print Service for Sales Invoices and Customer Statements.
class PdfExportService {
  /// Generates printable HTML string for a Single Sales Invoice.
  static String generateInvoiceHtml({
    required SaleEntity sale,
    required String shopName,
    required String shopPhone,
    required String currencySymbol,
  }) {
    developer.log('📄 [PdfExportService] Generating HTML Invoice Memo for ${sale.invoiceNo}', name: 'PdfExportService');

    final itemsRows = sale.items.map((cartItem) {
      final total = cartItem.quantity * cartItem.item.retailSellPrice;
      return '''
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">${cartItem.item.name}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: center;">${cartItem.quantity}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: right;">$currencySymbol${cartItem.item.retailSellPrice.toStringAsFixed(2)}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: right;">$currencySymbol${total.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join('');

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Invoice ${sale.invoiceNo}</title>
        <style>
          body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333; margin: 20px; }
          .header { text-align: center; margin-bottom: 20px; }
          .header h2 { margin: 0; color: #1e293b; }
          .header p { margin: 4px 0; color: #64748b; font-size: 14px; }
          .info-table { width: 100%; margin-bottom: 20px; font-size: 14px; }
          .items-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
          .items-table th { background: #f1f5f9; padding: 10px; text-align: left; font-size: 13px; color: #475569; }
          .total-section { float: right; width: 250px; font-size: 14px; }
          .total-row { display: flex; justify-content: space-between; padding: 4px 0; }
          .total-row.grand { font-weight: bold; font-size: 16px; border-top: 2px solid #333; padding-top: 8px; color: #0f172a; }
          .footer { margin-top: 60px; text-align: center; font-size: 12px; color: #94a3b8; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>$shopName</h2>
          <p>Phone: $shopPhone</p>
          <h3 style="margin-top: 10px; color: #2563eb;">SALES INVOICE</h3>
        </div>

        <table class="info-table">
          <tr>
            <td><strong>Invoice No:</strong> ${sale.invoiceNo}</td>
            <td style="text-align: right;"><strong>Date:</strong> ${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}</td>
          </tr>
          <tr>
            <td><strong>Customer:</strong> ${sale.customer?.name ?? "Walk-in Customer"}</td>
            <td style="text-align: right;"><strong>Phone:</strong> ${sale.customer?.phone ?? "N/A"}</td>
          </tr>
        </table>

        <table class="items-table">
          <thead>
            <tr>
              <th>Item Name</th>
              <th style="text-align: center;">Qty</th>
              <th style="text-align: right;">Unit Price</th>
              <th style="text-align: right;">Total</th>
            </tr>
          </thead>
          <tbody>
            $itemsRows
          </tbody>
        </table>

        <div class="total-section">
          <div class="total-row"><span>Subtotal:</span> <span>$currencySymbol${sale.subtotal.toStringAsFixed(2)}</span></div>
          <div class="total-row"><span>Discount:</span> <span>-$currencySymbol${sale.discountAmount.toStringAsFixed(2)}</span></div>
          <div class="total-row"><span>VAT:</span> <span>+$currencySymbol${sale.vatAmount.toStringAsFixed(2)}</span></div>
          <div class="total-row grand"><span>Net Total:</span> <span>$currencySymbol${sale.netTotal.toStringAsFixed(2)}</span></div>
          <div class="total-row" style="color: #16a34a;"><span>Paid Amount:</span> <span>$currencySymbol${sale.paidAmount.toStringAsFixed(2)}</span></div>
          <div class="total-row" style="color: #dc2626; font-weight: bold;"><span>Due Amount:</span> <span>$currencySymbol${sale.dueAmount.toStringAsFixed(2)}</span></div>
        </div>

        <div style="clear: both;"></div>

        <div class="footer">
          <p>Thank you for your business!</p>
          <p>Software generated invoice by Smart Inventory POS</p>
        </div>
      </body>
      </html>
    ''';
  }

  /// Generates printable HTML string for Customer Transaction Ledger Statement.
  static String generateCustomerLedgerHtml({
    required CustomerEntity customer,
    required List<SaleEntity> customerSales,
    required String shopName,
    required String currencySymbol,
  }) {
    developer.log('📄 [PdfExportService] Generating Customer Ledger Statement for ${customer.name}', name: 'PdfExportService');

    final salesRows = customerSales.map((sale) {
      return '''
        <tr>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd;">${sale.invoiceNo}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: right;">$currencySymbol${sale.netTotal.toStringAsFixed(2)}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: right; color: #16a34a;">$currencySymbol${sale.paidAmount.toStringAsFixed(2)}</td>
          <td style="padding: 8px; border-bottom: 1px solid #ddd; text-align: right; color: #dc2626; font-weight: bold;">$currencySymbol${sale.dueAmount.toStringAsFixed(2)}</td>
        </tr>
      ''';
    }).join('');

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Customer Ledger Statement - ${customer.name}</title>
        <style>
          body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333; margin: 20px; }
          .header { text-align: center; margin-bottom: 20px; }
          .header h2 { margin: 0; color: #1e293b; }
          .customer-card { background: #f8fafc; border: 1px solid #e2e8f0; padding: 14px; border-radius: 8px; margin-bottom: 20px; }
          .items-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
          .items-table th { background: #f1f5f9; padding: 10px; text-align: left; font-size: 13px; color: #475569; }
          .footer { margin-top: 40px; text-align: center; font-size: 12px; color: #94a3b8; }
        </style>
      </head>
      <body>
        <div class="header">
          <h2>$shopName</h2>
          <h3 style="color: #2563eb;">CUSTOMER LEDGER STATEMENT</h3>
        </div>

        <div class="customer-card">
          <table style="width: 100%;">
            <tr>
              <td><strong>Customer Name:</strong> ${customer.name}</td>
              <td style="text-align: right;"><strong>Phone:</strong> ${customer.phone}</td>
            </tr>
            <tr>
              <td><strong>Opening Balance:</strong> $currencySymbol${customer.openingBalance.toStringAsFixed(2)}</td>
              <td style="text-align: right; color: #dc2626;"><strong>Total Due:</strong> $currencySymbol${customer.totalDue.toStringAsFixed(2)}</td>
            </tr>
          </table>
        </div>

        <table class="items-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Invoice No</th>
              <th style="text-align: right;">Total Amount</th>
              <th style="text-align: right;">Paid Amount</th>
              <th style="text-align: right;">Due Amount</th>
            </tr>
          </thead>
          <tbody>
            $salesRows
          </tbody>
        </table>

        <div class="footer">
          <p>End of Customer Statement - Generated by Smart Inventory POS</p>
        </div>
      </body>
      </html>
    ''';
  }
}
