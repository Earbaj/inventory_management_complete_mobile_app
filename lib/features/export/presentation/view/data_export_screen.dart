import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../../core/route/app_route.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../customers/customer_transaction.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../bloc/export_bloc.dart';
import '../bloc/export_event.dart';
import '../bloc/export_state.dart';
import '../widget/export_action_card.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  CustomerEntity? _selectedCustomerForLedger;
  bool _isLoadingLedgerPdf = false;

  void _showCsvPreviewDialog(String fileName, String csvContent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.table_chart_rounded, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: SelectableText(
                csvContent.isNotEmpty ? csvContent : 'Exported file is empty.',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
            onPressed: () {
              Printing.sharePdf(
                bytes: Uint8List.fromList(csvContent.codeUnits),
                filename: fileName,
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Save / Share CSV'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportInventoryPdf() async {
    final invState = context.read<InventoryBloc>().state;
    final items = invState is InventoryLoadedState ? invState.items : [];

    final pdfBytes = await PdfExportService.generateInventoryReportPdf(items: items);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'inventory_report.pdf',
    );
  }

  Future<void> _exportCustomersPdf() async {
    final custState = context.read<CustomerBloc>().state;
    final customers = custState is CustomerLoadedState ? custState.customers : [];

    final pdfBytes = await PdfExportService.generateCustomersListPdf(customers: customers);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'customers_list.pdf',
    );
  }

  Future<void> _exportSalesPdf() async {
    final reportsState = context.read<ReportsBloc>().state;
    final sales = reportsState is ReportsLoadedState ? reportsState.invoiceLogs : [];

    final pdfBytes = await PdfExportService.generateSalesReportPdf(
      sales: sales,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'sales_report.pdf',
    );
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static double _parseTotalFromDescription(String desc, double fallbackAmount) {
    final regExp = RegExp(r'Total:\s*([\d\.]+)');
    final match = regExp.firstMatch(desc);
    if (match != null && match.group(1) != null) {
      return double.tryParse(match.group(1)!) ?? fallbackAmount;
    }
    return fallbackAmount;
  }

  static String _extractRef(String typeStr, String desc, String fallbackId) {
    if (typeStr == 'return' || typeStr == 'credit_note') {
      final regExp = RegExp(r'#?(INV-[\w\-]+|RET-[\w\-]+)');
      final match = regExp.firstMatch(desc);
      if (match != null && match.group(1) != null) {
        return 'RET-${match.group(1)}';
      }
      final shortId = fallbackId.length > 6 ? fallbackId.substring(0, 6).toUpperCase() : fallbackId;
      return 'RETURN-$shortId';
    }
    final regExp = RegExp(r'#?(INV-[\w\-]+)');
    final match = regExp.firstMatch(desc);
    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }
    if (typeStr == 'payment') {
      final shortId = fallbackId.length > 6 ? fallbackId.substring(0, 6).toUpperCase() : fallbackId;
      return 'PAY-$shortId';
    }
    if (typeStr == 'opening') {
      return 'OPENING';
    }
    return fallbackId.length > 8 ? fallbackId.substring(0, 8).toUpperCase() : fallbackId;
  }

  Future<void> _exportLedgerPdf() async {
    if (_selectedCustomerForLedger == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first to export PDF ledger statement!')),
      );
      return;
    }

    setState(() => _isLoadingLedgerPdf = true);

    try {
      final data = await InjectionContainer.customerRemoteDataSource.getCustomerLedger(
        customerId: _selectedCustomerForLedger!.id,
      );

      final Map<String, dynamic> payload = data;
      final List rawList = payload['data'] is List
          ? payload['data']
          : (payload['ledger'] is List ? payload['ledger'] : (payload['transactions'] is List ? payload['transactions'] : []));

      final List<CustomerTransaction> parsedTransactions = [];

      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        if (item is Map<String, dynamic>) {
          final String typeStr = item['type']?.toString().toLowerCase() ?? 'sale';
          final String desc = item['description']?.toString() ?? '';
          final double rawAmount = _parseDouble(item['amount']);
          final double amountAbs = rawAmount.abs();
          final double newBal = _parseDouble(item['newBalance'] ?? item['new_balance']);
          final String idStr = item['id']?.toString() ?? item['referenceId']?.toString() ?? UniqueKey().toString();
          final DateTime date = DateTime.tryParse(item['date']?.toString() ?? item['createdAt']?.toString() ?? '') ?? DateTime.now();

          final TransactionType type = typeStr == 'opening'
              ? TransactionType.opening
              : (typeStr == 'payment' || typeStr == 'due_payment')
                  ? TransactionType.payment
                  : ((typeStr == 'return' || typeStr == 'credit_note') ? TransactionType.returnInvoice : TransactionType.sale);

          parsedTransactions.add(CustomerTransaction(
            id: idStr,
            date: date,
            reference: _extractRef(typeStr, desc, idStr),
            type: type,
            amount: typeStr == 'sale' ? _parseTotalFromDescription(desc, amountAbs) : amountAbs,
            runningBalance: newBal,
            note: desc,
          ));
        }
      }

      final pdfBytes = await PdfExportService.generateCustomerStatementPdf(
        customer: _selectedCustomerForLedger!,
        transactions: parsedTransactions,
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
      );

      if (mounted) {
        setState(() => _isLoadingLedgerPdf = false);
      }

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'customer_ledger_${_selectedCustomerForLedger!.name}.pdf',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLedgerPdf = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ledger: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Fetch customer list for ledger dropdown
    final custSnapshot = context.watch<CustomerBloc>().state;
    final List<CustomerEntity> customerList = custSnapshot is CustomerLoadedState ? custSnapshot.customers : [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
        title: const Row(
          children: [
            Icon(Icons.download_for_offline_rounded, size: 24),
            SizedBox(width: 8),
            Text('Bulk Data Export'),
          ],
        ),
      ),
      body: BlocConsumer<ExportBloc, ExportState>(
        listener: (context, state) {
          if (state is ExportSuccessState) {
            _showCsvPreviewDialog(state.exportFile.fileName, state.exportFile.csvContent);
          } else if (state is ExportErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ExportLoadingState;
          final loadingMsg = state is ExportLoadingState ? state.message : '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // BANNER HEADER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_download_rounded, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Bulk CSV & PDF Exporter',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Export shop inventory, customer due balances, sales invoices, and customer ledgers to CSV or print official PDF statements.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),

              if (isLoading) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loadingMsg,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 1. INVENTORY EXPORT CARD
              ExportActionCard(
                title: '1. Export Product Inventory',
                description: 'Export all warehouse items, stock counts, cost prices & selling rates.',
                icon: Icons.inventory_2_outlined,
                iconColor: Colors.blue,
                isLoading: isLoading,
                onExportCsv: () {
                  context.read<ExportBloc>().add(const TriggerExportInventoryEvent());
                },
                onExportPdf: _exportInventoryPdf,
              ),

              // 2. CUSTOMERS EXPORT CARD
              ExportActionCard(
                title: '2. Export Customer List & Due Balances',
                description: 'Export all registered customer profiles, contact numbers & due balances.',
                icon: Icons.people_outline,
                iconColor: Colors.orange.shade800,
                isLoading: isLoading,
                onExportCsv: () {
                  context.read<ExportBloc>().add(const TriggerExportCustomersEvent());
                },
                onExportPdf: _exportCustomersPdf,
              ),

              // 3. SALES INVOICES EXPORT CARD
              ExportActionCard(
                title: '3. Export Sales & Revenue Invoices',
                description: 'Export complete sales transaction log, discounts, VAT & net totals.',
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.purple,
                isLoading: isLoading,
                onExportCsv: () {
                  context.read<ExportBloc>().add(const TriggerExportSalesEvent());
                },
                onExportPdf: _exportSalesPdf,
              ),

              // 4. CUSTOMER LEDGER EXPORT CARD WITH CUSTOMER DROPDOWN
              Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_outlined, color: Colors.teal, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '4. Export Customer Ledger Statement',
                              maxLines: 2,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Export itemized statement of debits, credits & running balance for a customer.',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<CustomerEntity?>(
                        value: _selectedCustomerForLedger,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Select Customer to Export Ledger',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: customerList.map((c) {
                          return DropdownMenuItem<CustomerEntity?>(
                            value: c,
                            child: Text('${c.name} (${c.phone})', style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCustomerForLedger = val),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isLoading || _selectedCustomerForLedger == null || _isLoadingLedgerPdf
                                  ? null
                                  : () {
                                      context
                                          .read<ExportBloc>()
                                          .add(TriggerExportCustomerLedgerEvent(_selectedCustomerForLedger!.id));
                                    },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.table_chart_outlined, color: Colors.green, size: 18),
                              label: const Text(
                                'Export Ledger CSV',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.green),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: isLoading || _selectedCustomerForLedger == null || _isLoadingLedgerPdf
                                  ? null
                                  : _exportLedgerPdf,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: _isLoadingLedgerPdf
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                              label: Text(
                                _isLoadingLedgerPdf ? 'Loading...' : 'Export Ledger PDF',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
