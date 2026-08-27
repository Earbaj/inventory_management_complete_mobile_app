import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/customers/customer_transaction.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';
import '../../features/settings/domain/entities/shop_profile_entity.dart';
import '../di/injection_container.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';

/// Professional PDF Export & Print Service for Sales Invoices and Customer Statements.
class PdfExportService {
  /// Opens Interactive Native PDF Print Preview & Device Save / Share dialog for an Invoice.
  static Future<void> printOrSaveInvoicePdf(
    BuildContext context, {
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
  }) async {
    developer.log('📄 [PdfExportService] Opening PDF Print Preview for Invoice ${sale.invoiceNo}', name: 'PdfExportService');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return generateInvoicePdfBytes(sale: sale, shopProfile: shopProfile);
      },
      name: 'Invoice_${sale.invoiceNo}',
    );
  }

  /// Opens Interactive Native PDF Print Preview & Device Save / Share dialog for Customer Statement.
  static Future<void> printOrSaveCustomerLedgerPdf(
    BuildContext context, {
    required CustomerEntity customer,
    required List<CustomerTransaction> transactions,
    required ShopProfileEntity shopProfile,
  }) async {
    developer.log('📄 [PdfExportService] Opening PDF Print Preview for Customer ${customer.name}', name: 'PdfExportService');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return generateCustomerLedgerPdfBytes(
          customer: customer,
          transactions: transactions,
          shopProfile: shopProfile,
        );
      },
      name: 'Statement_${customer.name.replaceAll(' ', '_')}',
    );
  }

  /// Generates Uint8List PDF Bytes for a Single Sales Invoice.
  static Future<Uint8List> generateInvoicePdfBytes({
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
  }) async {
    final pdf = pw.Document();

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';
    final shopName = shopProfile.shopName.isNotEmpty ? shopProfile.shopName : 'INVENTORY POS STORE';
    final shopPhone = shopProfile.phone.isNotEmpty ? shopProfile.phone : 'N/A';
    final shopAddress = shopProfile.address?.isNotEmpty == true ? shopProfile.address! : '';
    final shopEmail = shopProfile.email?.isNotEmpty == true ? shopProfile.email! : '';

    final dateStr = '${sale.createdAt.day.toString().padLeft(2, '0')}/'
        '${sale.createdAt.month.toString().padLeft(2, '0')}/'
        '${sale.createdAt.year} ${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. SHOP HEADER & LOGO/ADDRESS
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      shopName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (sale.branchName != null && sale.branchName!.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Branch: ${sale.branchName}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                    if (shopAddress.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        shopAddress,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Phone: $shopPhone${shopEmail.isNotEmpty ? ' | Email: $shopEmail' : ''}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue800,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'SALES INVOICE RECEIPT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],
                ),
              ),

              // 2. INVOICE META & CUSTOMER DETAILS TABLE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice No: ${sale.invoiceNo}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Customer: ${sale.customer?.name ?? "Walk-in Customer"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Phone: ${sale.customer?.phone ?? "N/A"}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              // 3. PURCHASED ITEMS TABLE
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headers: ['Item Description', 'Qty', 'Unit Price', 'Total Amount'],
                data: sale.items.map((cartItem) {
                  final total = cartItem.quantity * cartItem.item.retailSellPrice;
                  return [
                    cartItem.item.name,
                    '${cartItem.quantity}',
                    '$currency${cartItem.item.retailSellPrice.toStringAsFixed(2)}',
                    '$currency${total.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 16),

              // 4. TOTALS SUMMARY BREAKDOWN
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfSummaryRow('Subtotal:', '$currency${sale.subtotal.toStringAsFixed(2)}'),
                        if (sale.discountAmount > 0)
                          _buildPdfSummaryRow('Discount:', '-$currency${sale.discountAmount.toStringAsFixed(2)}'),
                        if (sale.vatAmount > 0)
                          _buildPdfSummaryRow('VAT:', '+$currency${sale.vatAmount.toStringAsFixed(2)}'),
                        pw.Divider(color: PdfColors.grey400),
                        _buildPdfSummaryRow(
                          'Net Total:',
                          '$currency${sale.netTotal.toStringAsFixed(2)}',
                          isBold: true,
                          fontSize: 12,
                        ),
                        _buildPdfSummaryRow(
                          'Paid Amount:',
                          '$currency${sale.paidAmount.toStringAsFixed(2)}',
                          color: PdfColors.green800,
                        ),
                        _buildPdfSummaryRow(
                          'Due Amount:',
                          '$currency${sale.dueAmount.toStringAsFixed(2)}',
                          isBold: sale.dueAmount > 0,
                          color: sale.dueAmount > 0 ? PdfColors.red800 : PdfColors.grey800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates Uint8List PDF Bytes for Customer Ledger Statement.
  static Future<Uint8List> generateCustomerLedgerPdfBytes({
    required CustomerEntity customer,
    required List<CustomerTransaction> transactions,
    required ShopProfileEntity shopProfile,
  }) async {
    final pdf = pw.Document();

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';
    final shopName = shopProfile.shopName.isNotEmpty ? shopProfile.shopName : 'INVENTORY POS STORE';
    final shopPhone = shopProfile.phone.isNotEmpty ? shopProfile.phone : 'N/A';
    final shopAddress = shopProfile.address?.isNotEmpty == true ? shopProfile.address! : '';

    final sortedTxs = List<CustomerTransaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final tableData = sortedTxs.map((tx) {
      final dateStr = '${tx.date.day.toString().padLeft(2, '0')}/'
          '${tx.date.month.toString().padLeft(2, '0')}/'
          '${tx.date.year}';

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

      final debitStr = debit > 0 ? '$currency${debit.toStringAsFixed(2)}' : '-';
      final creditStr = credit > 0 ? '$currency${credit.toStringAsFixed(2)}' : '-';

      final balStr = tx.runningBalance < 0
          ? '$currency${tx.runningBalance.abs().toStringAsFixed(2)} (Due)'
          : (tx.runningBalance > 0
              ? '$currency${tx.runningBalance.toStringAsFixed(2)} (Credit)'
              : '$currency');

      return [
        dateStr,
        tx.reference,
        desc,
        debitStr,
        creditStr,
        balStr,
      ];
    }).toList();

    final closingBalanceStr = customer.rawBalance < 0
        ? '$currency${customer.rawBalance.abs().toStringAsFixed(2)} (Due)'
        : (customer.rawBalance > 0
            ? '$currency${customer.rawBalance.toStringAsFixed(2)} (Credit)'
            : '$currency');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(shopName.toUpperCase(), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    if (shopAddress.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(shopAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                    pw.SizedBox(height: 2),
                    pw.Text('Phone: $shopPhone', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.SizedBox(height: 12),
                    pw.Text('CUSTOMER LEDGER STATEMENT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.SizedBox(height: 16),
                  ],
                ),
              ),

              // CUSTOMER SUMMARY CARD
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Customer Name: ${customer.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.Text('Phone: ${customer.phone}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Opening Balance: $currency${customer.openingBalance.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text('Total Due: $currency${customer.totalDue.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Closing Balance: $closingBalanceStr',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                            color: customer.rawBalance < 0 ? PdfColors.red800 : PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // INVOICE TABLE
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
                headers: ['Date', 'Reference', 'Description', 'Debit (+)', 'Credit (-)', 'Balance'],
                data: tableData,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey800)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Generates printable HTML string for a Single Sales Invoice (Backward Compatibility).
  static String generateInvoiceHtml({
    required SaleEntity sale,
    required String shopName,
    required String shopPhone,
    required String currencySymbol,
  }) {
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
      </head>
      <body>
        <h2>$shopName</h2>
        <p>Phone: $shopPhone</p>
        <table>$itemsRows</table>
      </body>
      </html>
    ''';
  }

  /// Generates printable HTML string for Customer Transaction Ledger Statement (Backward Compatibility).
  static String generateCustomerLedgerHtml({
    required CustomerEntity customer,
    required List<SaleEntity> customerSales,
    required String shopName,
    required String currencySymbol,
  }) {
    return '''
      <!DOCTYPE html>
      <html>
      <body>
        <h2>$shopName</h2>
        <h3>Customer Statement: ${customer.name}</h3>
      </body>
      </html>
    ''';
  }

  static Future<Uint8List> generateInventoryReportPdf({required List<dynamic> items}) async {
    final pdf = pw.Document();

    // Get shop profile
    ShopProfileEntity shopProfile = const ShopProfileEntity(
      id: 'default',
      shopName: 'INVENTORY POS STORE',
      phone: 'N/A',
      currencySymbol: '৳',
    );
    try {
      final settingsState = InjectionContainer.settingsBloc.state;
      if (settingsState is SettingsLoadedState) {
        shopProfile = settingsState.profile;
      }
    } catch (_) {}

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(shopProfile.shopName.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('INVENTORY REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Item Name', 'SKU', 'Category', 'Stock Qty', 'Sell Price', 'Cost Price'],
              data: items.map((item) {
                return [
                  item.name,
                  item.sku,
                  item.category,
                  '${item.stockQuantity} ${item.unit}',
                  '$currency${item.retailSellPrice.toStringAsFixed(2)}',
                  '$currency${item.purchasePrice.toStringAsFixed(2)}',
                ];
              }).toList(),
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ];
        },
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generateCustomersListPdf({required List<dynamic> customers}) async {
    final pdf = pw.Document();

    ShopProfileEntity shopProfile = const ShopProfileEntity(
      id: 'default',
      shopName: 'INVENTORY POS STORE',
      phone: 'N/A',
      currencySymbol: '৳',
    );
    try {
      final settingsState = InjectionContainer.settingsBloc.state;
      if (settingsState is SettingsLoadedState) {
        shopProfile = settingsState.profile;
      }
    } catch (_) {}

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(shopProfile.shopName.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('CUSTOMERS LIST REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Customer Name', 'Phone', 'Email', 'Address', 'Current Balance'],
              data: customers.map((c) {
                final double bal = c.rawBalance;
                final balStr = bal < 0
                    ? '$currency${bal.abs().toStringAsFixed(2)} (Due)'
                    : (bal > 0 ? '$currency${bal.toStringAsFixed(2)} (Credit)' : '$currency 0.00');
                return [
                  c.name,
                  c.phone,
                  c.email ?? 'N/A',
                  c.address ?? 'N/A',
                  balStr,
                ];
              }).toList(),
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ];
        },
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generateSalesReportPdf({
    required List<dynamic> sales,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    ShopProfileEntity shopProfile = const ShopProfileEntity(
      id: 'default',
      shopName: 'INVENTORY POS STORE',
      phone: 'N/A',
      currencySymbol: '৳',
    );
    try {
      final settingsState = InjectionContainer.settingsBloc.state;
      if (settingsState is SettingsLoadedState) {
        shopProfile = settingsState.profile;
      }
    } catch (_) {}

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';

    final dateRangeStr = 'Period: ${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(shopProfile.shopName.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('SALES REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.SizedBox(height: 2),
                  pw.Text(dateRangeStr, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  pw.SizedBox(height: 12),
                ],
              ),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Invoice No', 'Date', 'Customer', 'Net Total', 'Paid', 'Due', 'Payment'],
              data: sales.map((sale) {
                final dateStr = '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
                return [
                  sale.invoiceNo,
                  dateStr,
                  sale.customer?.name ?? 'Walk-in',
                  '$currency${sale.netTotal.toStringAsFixed(2)}',
                  '$currency${sale.paidAmount.toStringAsFixed(2)}',
                  '$currency${sale.dueAmount.toStringAsFixed(2)}',
                  sale.paymentMethod.toUpperCase(),
                ];
              }).toList(),
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
              ),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
              cellStyle: const pw.TextStyle(fontSize: 9),
            ),
          ];
        },
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generateCustomerStatementPdf({
    required CustomerEntity customer,
    required List<dynamic> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get settings/shop profile
    ShopProfileEntity shopProfile = const ShopProfileEntity(
      id: 'default',
      shopName: 'INVENTORY POS STORE',
      phone: 'N/A',
      currencySymbol: '৳',
    );
    try {
      final settingsState = InjectionContainer.settingsBloc.state;
      if (settingsState is SettingsLoadedState) {
        shopProfile = settingsState.profile;
      }
    } catch (_) {}

    // Map list of dynamic transactions to CustomerTransaction
    final List<CustomerTransaction> castedTransactions = transactions.cast<CustomerTransaction>().toList();

    return generateCustomerLedgerPdfBytes(
      customer: customer,
      transactions: castedTransactions,
      shopProfile: shopProfile,
    );
  }
}
