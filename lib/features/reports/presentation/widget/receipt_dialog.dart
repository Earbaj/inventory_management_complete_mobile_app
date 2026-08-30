import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customers/domain/entities/customer_entity.dart';
import '../../../inventory/domain/entities/inventory_item_entity.dart';
import '../../../posbilling/domain/entities/cart_item_entity.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../settings/domain/entities/shop_profile_entity.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../reports_models.dart';

class ReceiptDialog extends StatelessWidget {
  final InvoiceLog invoice;

  const ReceiptDialog({
    super.key,
    required this.invoice,
  });

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

  SaleEntity _toSaleEntity(InvoiceLog log) {
    return SaleEntity(
      id: log.id,
      invoiceNo: log.invoiceNumber,
      customer: CustomerEntity(
        id: '',
        name: log.customerName,
        phone: log.customerPhone,
        openingBalance: 0.0,
      ),
      items: log.items.map((i) {
        return CartItemEntity(
          item: InventoryItemEntity(
            id: i.itemId,
            name: i.name,
            sku: '',
            category: 'General',
            unit: 'pcs',
            stockQuantity: 100,
            lowStockQuantity: 5,
            retailSellPrice: i.unitPrice,
            purchasePrice: i.unitPrice,
          ),
          quantity: i.quantity,
        );
      }).toList(),
      subtotal: log.totalAmount,
      discountAmount: 0.0,
      vatAmount: 0.0,
      netTotal: log.totalAmount,
      paidAmount: log.paidAmount,
      dueAmount: log.dueAmount,
      paymentMethod: 'cash',
      createdAt: log.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dynamically resolve Shop Profile from AuthBloc (Admin registration profile) & SettingsBloc
    final authState = InjectionContainer.authBloc.state;
    final user = authState is AuthenticatedState ? authState.user : null;

    final settingsState = InjectionContainer.settingsBloc.state;
    final profile = settingsState is SettingsLoadedState ? settingsState.profile : null;

    final shopName = (user?.shopName?.isNotEmpty == true ? user!.shopName : null) ??
        (profile?.shopName.isNotEmpty == true ? profile!.shopName : null) ??
        'INVENTORY POS STORE';

    final shopPhone = (user?.phone?.isNotEmpty == true ? user!.phone : null) ??
        (profile?.phone.isNotEmpty == true ? profile!.phone : null) ??
        'N/A';

    final shopAddress = profile?.address?.isNotEmpty == true ? profile!.address! : '';

    final dynamicShopProfile = ShopProfileEntity(
      id: profile?.id ?? user?.id ?? '',
      shopName: shopName,
      phone: shopPhone,
      address: shopAddress,
      email: user?.email ?? profile?.email,
      currencySymbol: 'Tk ',
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invoice Receipt PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Printable Receipt Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic Store Profile Header from Auth & Settings API
                      Center(
                        child: Column(
                          children: [
                            Text(
                              shopName.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (shopAddress.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                shopAddress,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              'Phone: $shopPhone',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            const Divider(thickness: 1),
                          ],
                        ),
                      ),

                      // Meta details
                      _buildInfoRow('Invoice No:', invoice.invoiceNumber, isBold: true),
                      _buildInfoRow('Date:', _formatDate(invoice.date)),
                      _buildInfoRow('Customer:', '${invoice.customerName} (${invoice.customerPhone})'),
                      _buildInfoRow('Served By:', invoice.servedBy),
                      const SizedBox(height: 8),
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),

                      // Items list table header
                      const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Item',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Total',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Divider(height: 1),
                      const SizedBox(height: 6),

                      // Items list rows
                      ...invoice.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Text(
                                      '${MoneyUtil.currencySymbol}${item.unitPrice.toStringAsFixed(2)} each',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'x${item.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${MoneyUtil.currencySymbol}${item.totalRevenue.toStringAsFixed(2)}',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),

                      // Totals Summary
                      _buildSummaryRow('Total Amount', '${MoneyUtil.currencySymbol}${invoice.totalAmount.toStringAsFixed(2)}', isLarge: true),
                      _buildSummaryRow('Paid Amount', '${MoneyUtil.currencySymbol}${invoice.paidAmount.toStringAsFixed(2)}'),
                      _buildSummaryRow('Due Amount', '${MoneyUtil.currencySymbol}${invoice.dueAmount.toStringAsFixed(2)}',
                          color: invoice.dueAmount > 0 ? Colors.red : Colors.green),

                      const SizedBox(height: 10),

                      // Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: invoice.paymentStatus.backgroundColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              invoice.paymentStatus.label.toUpperCase(),
                              style: TextStyle(
                                color: invoice.paymentStatus.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final saleEntity = _toSaleEntity(invoice);
                        PdfExportService.printOrSaveInvoicePdf(
                          context,
                          sale: saleEntity,
                          shopProfile: dynamicShopProfile,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Save PDF'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final saleEntity = _toSaleEntity(invoice);
                        PdfExportService.printOrSaveInvoicePdf(
                          context,
                          sale: saleEntity,
                          shopProfile: dynamicShopProfile,
                        );
                      },
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Print Receipt'),
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

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isLarge = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isLarge ? FontWeight.bold : FontWeight.w500,
              fontSize: isLarge ? 14 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isLarge ? FontWeight.w800 : FontWeight.bold,
              fontSize: isLarge ? 15 : 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
