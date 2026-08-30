import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../settings/domain/entities/shop_profile_entity.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/entities/supplier_entity.dart';

class PurchaseOrderReceiptDialog extends StatefulWidget {
  final PurchaseOrderEntity order;
  final SupplierEntity? supplier;

  const PurchaseOrderReceiptDialog({
    super.key,
    required this.order,
    this.supplier,
  });

  static Future<void> show(
    BuildContext context, {
    required PurchaseOrderEntity order,
    SupplierEntity? supplier,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PurchaseOrderReceiptDialog(
        order: order,
        supplier: supplier,
      ),
    );
  }

  @override
  State<PurchaseOrderReceiptDialog> createState() => _PurchaseOrderReceiptDialogState();
}

class _PurchaseOrderReceiptDialogState extends State<PurchaseOrderReceiptDialog> {
  bool _isGeneratingPdf = false;

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month ${dt.year}, $hour:$minute $period';
  }

  Future<void> _printPdf() async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);

    try {
      ShopProfileEntity? profile;
      final settingsState = InjectionContainer.settingsBloc.state;
      if (settingsState is SettingsLoadedState) {
        profile = settingsState.profile;
      }

      await PdfExportService.printOrSavePurchaseOrderPdf(
        context,
        order: widget.order,
        supplier: widget.supplier,
        shopProfile: profile,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = widget.order;
    final poNumber = order.poNumber.isNotEmpty
        ? order.poNumber
        : '#${order.id.length > 8 ? order.id.substring(order.id.length - 6) : order.id}';

    // Get current shop profile if available
    String shopName = 'SMART INVENTORY STORE';
    String shopPhone = '';
    final settingsState = InjectionContainer.settingsBloc.state;
    if (settingsState is SettingsLoadedState) {
      if (settingsState.profile.shopName.isNotEmpty) {
        shopName = settingsState.profile.shopName;
      }
      shopPhone = settingsState.profile.phone;
    }

    final isPaid = order.dueAmount <= 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Voucher',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          poNumber,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Scrollable Receipt Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            shopName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (shopPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Phone: $shopPhone',
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPaid ? Colors.green.shade300 : Colors.orange.shade300,
                              ),
                            ),
                            child: Text(
                              isPaid ? 'STATUS: PAID' : 'STATUS: DUE PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isPaid ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Order & Supplier Info Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Date & Time:', _formatDate(order.createdAt)),
                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'Supplier:',
                            order.supplierName.isNotEmpty
                                ? order.supplierName
                                : (widget.supplier?.name ?? 'N/A'),
                            isBold: true,
                          ),
                          if (widget.supplier?.companyName.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Company:', widget.supplier!.companyName),
                          ],
                          if (widget.supplier?.phone.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            _buildDetailRow('Phone:', widget.supplier!.phone),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Purchased Items Section
                    Text(
                      'PURCHASED ITEMS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Table Items
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      item.itemName,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '৳${item.unitCost.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      '৳${item.totalPrice.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Financial Summary Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Total Bill Amount:', '৳ ${order.totalAmount.toStringAsFixed(2)}', isBold: true),
                          const SizedBox(height: 6),
                          _buildSummaryRow('Paid Amount:', '৳ ${order.paidAmount.toStringAsFixed(2)}'),
                          const Divider(height: 12),
                          _buildSummaryRow(
                            'Balance Due:',
                            '৳ ${order.dueAmount.toStringAsFixed(2)}',
                            isBold: true,
                            valueColor: order.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),

                    if (order.note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_rounded, size: 16, color: Colors.amber.shade800),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Note: ${order.note}',
                                style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isGeneratingPdf ? null : _printPdf,
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.print_rounded, size: 18),
                      label: Text(_isGeneratingPdf ? 'Generating...' : 'Print / Save PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
