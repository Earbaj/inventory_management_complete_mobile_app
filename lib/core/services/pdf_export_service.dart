import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/customers/domain/entities/customer_entity.dart';
import '../../features/customers/customer_transaction.dart';
import '../../features/posbilling/domain/entities/sale_entity.dart';
import '../../features/suppliers/domain/entities/purchase_order_entity.dart';
import '../../features/suppliers/domain/entities/supplier_entity.dart';
import '../../features/settings/domain/entities/shop_profile_entity.dart';
import '../di/injection_container.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';

/// Available Invoice PDF Print Template Formats
enum InvoicePdfFormat {
  classic,
  modern,
  thermalPos;

  String get id {
    switch (this) {
      case InvoicePdfFormat.classic:
        return 'classic';
      case InvoicePdfFormat.modern:
        return 'modern';
      case InvoicePdfFormat.thermalPos:
        return 'thermal_pos';
    }
  }

  String get title {
    switch (this) {
      case InvoicePdfFormat.classic:
        return 'Classic Standard (A4)';
      case InvoicePdfFormat.modern:
        return 'Modern Minimal (A4)';
      case InvoicePdfFormat.thermalPos:
        return 'Compact POS Thermal (80mm)';
    }
  }

  String get subtitle {
    switch (this) {
      case InvoicePdfFormat.classic:
        return 'Traditional structured A4 invoice with standard tables & official header';
      case InvoicePdfFormat.modern:
        return 'Contemporary layout with brand accent, status badges & clean typography';
      case InvoicePdfFormat.thermalPos:
        return '80mm receipt roll layout formatted for thermal slip printers';
    }
  }

  static InvoicePdfFormat fromString(String? val) {
    if (val == 'modern') return InvoicePdfFormat.modern;
    if (val == 'thermal_pos' || val == 'thermalPos' || val == 'pos') return InvoicePdfFormat.thermalPos;
    return InvoicePdfFormat.classic;
  }
}

/// Professional PDF Export & Print Service for Sales Invoices and Customer Statements.
class PdfExportService {
  static const String _prefFormatKey = 'selected_invoice_pdf_format';
  static InvoicePdfFormat _cachedFormat = InvoicePdfFormat.classic;
  static bool _hasLoadedFormat = false;

  /// Loads saved PDF template format preference from SharedPreferences.
  static Future<InvoicePdfFormat> getSavedInvoicePdfFormat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStr = prefs.getString(_prefFormatKey);
      _cachedFormat = InvoicePdfFormat.fromString(savedStr);
      _hasLoadedFormat = true;
      return _cachedFormat;
    } catch (_) {
      return _cachedFormat;
    }
  }

  /// Saves user's chosen PDF template format preference to SharedPreferences.
  static Future<void> saveInvoicePdfFormat(InvoicePdfFormat format) async {
    _cachedFormat = format;
    _hasLoadedFormat = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefFormatKey, format.id);
      developer.log('📄 [PdfExportService] Saved Invoice PDF Format preference: ${format.title}', name: 'PdfExportService');
    } catch (_) {}
  }

  /// Opens Interactive Native PDF Print Preview & Device Save / Share dialog for an Invoice.
  static Future<void> printOrSaveInvoicePdf(
    BuildContext context, {
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
    InvoicePdfFormat? format,
  }) async {
    final activeFormat = format ?? await getSavedInvoicePdfFormat();
    developer.log('📄 [PdfExportService] Opening PDF Print Preview for Invoice ${sale.invoiceNo} (Format: ${activeFormat.title})', name: 'PdfExportService');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat pageFormat) async {
        return generateInvoicePdfBytes(sale: sale, shopProfile: shopProfile, format: activeFormat);
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

  /// Opens Interactive Native PDF Print Preview & Device Save / Share dialog for a Purchase Order Voucher.
  static Future<void> printOrSavePurchaseOrderPdf(
    BuildContext context, {
    required PurchaseOrderEntity order,
    SupplierEntity? supplier,
    ShopProfileEntity? shopProfile,
  }) async {
    developer.log('📄 [PdfExportService] Opening PDF Print Preview for Purchase Order ${order.poNumber.isNotEmpty ? order.poNumber : order.id}', name: 'PdfExportService');

    ShopProfileEntity profile = shopProfile ?? const ShopProfileEntity(
      id: 'default',
      shopName: 'INVENTORY POS STORE',
      phone: 'N/A',
      currencySymbol: '৳',
    );
    if (shopProfile == null) {
      try {
        final settingsState = InjectionContainer.settingsBloc.state;
        if (settingsState is SettingsLoadedState) {
          profile = settingsState.profile;
        }
      } catch (_) {}
    }

    final poName = order.poNumber.isNotEmpty ? order.poNumber : 'PO_${order.id.length > 8 ? order.id.substring(order.id.length - 6) : order.id}';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return generatePurchaseOrderPdfBytes(order: order, supplier: supplier, shopProfile: profile);
      },
      name: 'Purchase_Order_$poName',
    );
  }

  /// Generates Uint8List PDF Bytes for a Single Purchase Order Voucher.
  static Future<Uint8List> generatePurchaseOrderPdfBytes({
    required PurchaseOrderEntity order,
    SupplierEntity? supplier,
    required ShopProfileEntity shopProfile,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';
    final shopName = shopProfile.shopName.isNotEmpty ? shopProfile.shopName : 'INVENTORY POS STORE';
    final shopPhone = shopProfile.phone.isNotEmpty ? shopProfile.phone : 'N/A';
    final shopAddress = shopProfile.address?.isNotEmpty == true ? shopProfile.address! : '';
    final shopEmail = shopProfile.email?.isNotEmpty == true ? shopProfile.email! : '';

    final dateStr = '${order.createdAt.day.toString().padLeft(2, '0')}/'
        '${order.createdAt.month.toString().padLeft(2, '0')}/'
        '${order.createdAt.year} ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    final poNo = order.poNumber.isNotEmpty ? order.poNumber : '#${order.id.length > 8 ? order.id.substring(order.id.length - 6) : order.id}';
    final supplierName = order.supplierName.isNotEmpty ? order.supplierName : (supplier?.name ?? 'Supplier');
    final companyName = supplier?.companyName ?? '';
    final supplierPhone = supplier?.phone ?? '';
    final supplierAddress = supplier?.address ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. SHOP HEADER
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
                        color: PdfColors.indigo800,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'PURCHASE ORDER VOUCHER',
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

              // 2. VOUCHER & SUPPLIER INFO ROW
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // PO Details
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PO Number: $poNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.SizedBox(height: 4),
                      pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        children: [
                          pw.Text('Status: ', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(
                            order.dueAmount > 0 ? 'DUE / PENDING' : 'PAID',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                              color: order.dueAmount > 0 ? PdfColors.red800 : PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Supplier Details
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Supplier: $supplierName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      if (companyName.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text('Company: $companyName', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                      if (supplierPhone.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text('Phone: $supplierPhone', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                      if (supplierAddress.isNotEmpty) ...[
                        pw.SizedBox(height: 2),
                        pw.Text('Address: $supplierAddress', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // 3. ITEMS TABLE
              pw.TableHelper.fromTextArray(
                headers: ['SL', 'Item Name / Description', 'Qty', 'Unit Cost', 'Total Amount'],
                data: order.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return [
                    '$idx',
                    item.itemName,
                    '${item.quantity}',
                    '$currency${item.unitCost.toStringAsFixed(2)}',
                    '$currency${item.totalPrice.toStringAsFixed(2)}',
                  ];
                }).toList(),
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey500, width: 1),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                cellStyle: const pw.TextStyle(fontSize: 9),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(40),
                  3: const pw.FixedColumnWidth(70),
                  4: const pw.FixedColumnWidth(80),
                },
              ),
              pw.SizedBox(height: 16),

              // 4. FINANCIAL SUMMARY
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Amount:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Text('$currency${order.totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Paid Amount:', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                            pw.Text('$currency${order.paidAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                          ],
                        ),
                        pw.Divider(height: 8, color: PdfColors.grey400),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Balance Due:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: order.dueAmount > 0 ? PdfColors.red800 : PdfColors.green800)),
                            pw.Text(
                              '$currency${order.dueAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: order.dueAmount > 0 ? PdfColors.red800 : PdfColors.green800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (order.note.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text('Note / Remarks: ${order.note}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
              ],

              pw.Spacer(),

              // 5. SIGNATURE FOOTER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text("Supplier's Signature", style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Generated automatically by Smart Inventory & POS Management System',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates Uint8List PDF Bytes for a Single Sales Invoice in the specified or saved template format.
  static Future<Uint8List> generateInvoicePdfBytes({
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
    InvoicePdfFormat? format,
  }) async {
    final activeFormat = format ?? await getSavedInvoicePdfFormat();
    switch (activeFormat) {
      case InvoicePdfFormat.classic:
        return _generateClassicInvoicePdf(sale: sale, shopProfile: shopProfile);
      case InvoicePdfFormat.modern:
        return _generateModernInvoicePdf(sale: sale, shopProfile: shopProfile);
      case InvoicePdfFormat.thermalPos:
        return _generateThermalPosInvoicePdf(sale: sale, shopProfile: shopProfile);
    }
  }

  /// FORMAT 1: Classic Standard Structured A4 Invoice
  static Future<Uint8List> _generateClassicInvoicePdf({
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

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
                      if (sale.servedBy.isNotEmpty)
                        pw.Text('Served By: ${sale.servedBy}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
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

              pw.Spacer(),

              // 5. SIGNATURE & FOOTER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text("Customer's Signature", style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey500),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! Generated by Smart Inventory & POS',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// FORMAT 2: Modern Minimal / Elegant Clean Corporate A4 Invoice
  static Future<Uint8List> _generateModernInvoicePdf({
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';
    final shopName = shopProfile.shopName.isNotEmpty ? shopProfile.shopName : 'INVENTORY POS STORE';
    final shopPhone = shopProfile.phone.isNotEmpty ? shopProfile.phone : 'N/A';
    final shopAddress = shopProfile.address?.isNotEmpty == true ? shopProfile.address! : '';
    final shopEmail = shopProfile.email?.isNotEmpty == true ? shopProfile.email! : '';

    final dateStr = '${sale.createdAt.day.toString().padLeft(2, '0')}/'
        '${sale.createdAt.month.toString().padLeft(2, '0')}/'
        '${sale.createdAt.year}';
    final timeStr = '${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}';

    final isPaid = sale.dueAmount <= 0;
    final primaryColor = PdfColor.fromInt(0xFF1E3A8A); // Deep Royal Indigo
    final lightAccent = PdfColor.fromInt(0xFFF1F5F9);  // Slate 100

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. MODERN TOP HEADER BAR
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Store branding with stylish vertical accent bar
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 4,
                        height: 48,
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            shopName,
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          if (sale.branchName != null && sale.branchName!.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Branch: ${sale.branchName}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                          ],
                          if (shopAddress.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(shopAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                          ],
                          pw.SizedBox(height: 2),
                          pw.Text('Tel: $shopPhone${shopEmail.isNotEmpty ? ' • $shopEmail' : ''}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                        ],
                      ),
                    ],
                  ),

                  // Right: Invoice Title, Number & Status Badge
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '#${sale.invoiceNo}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('Date: $dateStr • $timeStr', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                      pw.SizedBox(height: 6),
                      // Payment Status Pill
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: isPaid ? PdfColor.fromInt(0xFFDCFCE7) : PdfColor.fromInt(0xFFFEE2E2),
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text(
                          isPaid ? 'PAID IN FULL' : 'PAYMENT DUE',
                          style: pw.TextStyle(
                            color: isPaid ? PdfColor.fromInt(0xFF166534) : PdfColor.fromInt(0xFF991B1B),
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // 2. CLIENT & TRANSACTION INFO CARD
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: lightAccent,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILLED TO', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          sale.customer?.name.isNotEmpty == true ? sale.customer!.name : 'Walk-in Customer',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        if (sale.customer?.phone.isNotEmpty == true) ...[
                          pw.SizedBox(height: 2),
                          pw.Text('Phone: ${sale.customer!.phone}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('PAYMENT METHOD', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          sale.paymentMethod.toUpperCase(),
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor),
                        ),
                        if (sale.servedBy.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text('Cashier: ${sale.servedBy}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // 3. MODERN MINIMALIST ITEMS TABLE
              pw.TableHelper.fromTextArray(
                context: context,
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(
                  color: primaryColor,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                rowDecoration: const pw.BoxDecoration(),
                oddRowDecoration: pw.BoxDecoration(color: lightAccent),
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                },
                columnWidths: {
                  0: const pw.FixedColumnWidth(24),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FixedColumnWidth(70),
                  3: const pw.FixedColumnWidth(40),
                  4: const pw.FixedColumnWidth(80),
                },
                headers: ['#', 'Item Description', 'Unit Price', 'Qty', 'Amount'],
                data: sale.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final total = item.quantity * item.item.retailSellPrice;
                  return [
                    '$idx',
                    item.item.name,
                    '$currency${item.item.retailSellPrice.toStringAsFixed(2)}',
                    '${item.quantity}',
                    '$currency${total.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 18),

              // 4. FINANCIAL SUMMARY & TERMS
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Notes & Terms
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Terms & Conditions:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '1. Goods sold can be exchanged with valid invoice within 7 days.\n'
                          '2. For any inquiries, please contact our support phone.\n'
                          '3. Thank you for choosing our store!',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600, lineSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  // Right: Total Calculation Card
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: lightAccent,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      children: [
                        _buildPdfSummaryRow('Subtotal:', '$currency${sale.subtotal.toStringAsFixed(2)}'),
                        if (sale.discountAmount > 0)
                          _buildPdfSummaryRow('Discount:', '-$currency${sale.discountAmount.toStringAsFixed(2)}', color: PdfColors.green800),
                        if (sale.vatAmount > 0)
                          _buildPdfSummaryRow('VAT / Tax:', '+$currency${sale.vatAmount.toStringAsFixed(2)}'),
                        pw.Divider(height: 8, color: PdfColors.grey400),
                        // Grand Total Highlight
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Due:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.Text(
                                '$currency${sale.netTotal.toStringAsFixed(2)}',
                                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                        pw.Divider(height: 8, color: PdfColors.grey400),
                        _buildPdfSummaryRow('Paid Amount:', '$currency${sale.paidAmount.toStringAsFixed(2)}', color: PdfColors.green800),
                        _buildPdfSummaryRow(
                          'Balance Due:',
                          '$currency${sale.dueAmount.toStringAsFixed(2)}',
                          isBold: sale.dueAmount > 0,
                          color: sale.dueAmount > 0 ? PdfColors.red800 : PdfColors.grey800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // 5. SIGNATURE FOOTER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text("Customer's Signature", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 130, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Powered by Smart Inventory POS Management System',
                  style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// FORMAT 3: Compact POS Thermal 80mm Receipt Slip
  static Future<Uint8List> _generateThermalPosInvoicePdf({
    required SaleEntity sale,
    required ShopProfileEntity shopProfile,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

    final currency = (shopProfile.currencySymbol == '৳' || shopProfile.currencySymbol.isEmpty) ? 'Tk ' : '${shopProfile.currencySymbol} ';
    final shopName = shopProfile.shopName.isNotEmpty ? shopProfile.shopName : 'INVENTORY POS STORE';
    final shopPhone = shopProfile.phone.isNotEmpty ? shopProfile.phone : 'N/A';
    final shopAddress = shopProfile.address?.isNotEmpty == true ? shopProfile.address! : '';

    final dateStr = '${sale.createdAt.day.toString().padLeft(2, '0')}/'
        '${sale.createdAt.month.toString().padLeft(2, '0')}/'
        '${sale.createdAt.year} ${sale.createdAt.hour.toString().padLeft(2, '0')}:${sale.createdAt.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 4 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // STORE HEADER
              pw.Text(
                shopName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
              if (sale.branchName != null && sale.branchName!.isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Text('Branch: ${sale.branchName}', style: const pw.TextStyle(fontSize: 8)),
              ],
              if (shopAddress.isNotEmpty) ...[
                pw.SizedBox(height: 1),
                pw.Text(shopAddress, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              ],
              pw.Text('Phone: $shopPhone', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),

              pw.Text('====================================', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
              pw.Text('*** SALES RECEIPT ***', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('====================================', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
              pw.SizedBox(height: 2),

              // INVOICE META
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Invoice #: ${sale.invoiceNo}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $dateStr', style: const pw.TextStyle(fontSize: 7.5)),
                    pw.Text('Customer: ${sale.customer?.name ?? "Walk-in"}', style: const pw.TextStyle(fontSize: 7.5)),
                    if (sale.servedBy.isNotEmpty)
                      pw.Text('Served By: ${sale.servedBy}', style: const pw.TextStyle(fontSize: 7.5)),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Text('----------------------------------------------------', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),

              // ITEMS LIST TABLE
              pw.Table(
                columnWidths: const {
                  0: pw.FlexColumnWidth(3.5), // Item Name
                  1: pw.FlexColumnWidth(1.0), // Qty
                  2: pw.FlexColumnWidth(1.8), // Price
                  3: pw.FlexColumnWidth(2.0), // Total
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('ITEM', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text('PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                      pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...sale.items.map((cartItem) {
                    final total = cartItem.quantity * cartItem.item.retailSellPrice;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text(cartItem.item.name, style: const pw.TextStyle(fontSize: 7.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text('${cartItem.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text('$currency${cartItem.item.retailSellPrice.toStringAsFixed(0)}', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Text('$currency${total.toStringAsFixed(0)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.Text('----------------------------------------------------', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
              pw.SizedBox(height: 2),

              // FINANCIAL SUMMARY
              pw.Column(
                children: [
                  _buildThermalRow('Subtotal:', '$currency${sale.subtotal.toStringAsFixed(2)}'),
                  if (sale.discountAmount > 0)
                    _buildThermalRow('Discount:', '-$currency${sale.discountAmount.toStringAsFixed(2)}'),
                  if (sale.vatAmount > 0)
                    _buildThermalRow('VAT:', '+$currency${sale.vatAmount.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 2),
                  pw.Text('====================================', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  _buildThermalRow('NET TOTAL:', '$currency${sale.netTotal.toStringAsFixed(2)}', isBold: true, fontSize: 9.5),
                  pw.Text('====================================', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                  _buildThermalRow('Paid Amount:', '$currency${sale.paidAmount.toStringAsFixed(2)}'),
                  _buildThermalRow('Due Amount:', '$currency${sale.dueAmount.toStringAsFixed(2)}', isBold: sale.dueAmount > 0),
                  _buildThermalRow('Payment Method:', sale.paymentMethod.toUpperCase()),
                ],
              ),

              pw.SizedBox(height: 6),
              pw.Text('====================================', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
              pw.Text('*** THANK YOU! VISIT AGAIN ***', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.Text('Goods once sold exchangeable within 7 days', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
              pw.SizedBox(height: 6),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildThermalRow(String label, String value, {bool isBold = false, double fontSize = 7.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: fontSize, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  /// Generates Uint8List PDF Bytes for Customer Ledger Statement.
  static Future<Uint8List> generateCustomerLedgerPdfBytes({
    required CustomerEntity customer,
    required List<CustomerTransaction> transactions,
    required ShopProfileEntity shopProfile,
  }) async {
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

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
                // কলামের উইডথ সেট করার অংশ
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.5), // Date
                  1: pw.FlexColumnWidth(1.5), // Reference
                  2: pw.FlexColumnWidth(3.0), // Description (বেশি জায়গা দেওয়া হলো)
                  3: pw.FlexColumnWidth(1.5), // Debit (+)
                  4: pw.FlexColumnWidth(1.5), // Credit (-)
                  5: pw.FlexColumnWidth(1.5), // Balance
                },
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
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

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
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

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
              headers: ['Customer Name', 'Phone', 'Address', 'Current Balance'],
              data: customers.map((c) {
                final double bal = c.rawBalance;
                final balStr = bal < 0
                    ? '$currency${bal.abs().toStringAsFixed(2)} (Due)'
                    : (bal > 0 ? '$currency${bal.toStringAsFixed(2)} (Credit)' : '$currency 0.00');
                return [
                  c.name,
                  c.phone,
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
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
      ),
    );

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
