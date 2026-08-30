import 'package:flutter/material.dart';
import '../../domain/entities/purchase_order_entity.dart';
import '../../domain/entities/supplier_entity.dart';

class PurchaseOrderItemCard extends StatelessWidget {
  final PurchaseOrderEntity order;
  final SupplierEntity? supplier;
  final VoidCallback onTap;
  final VoidCallback onPrintPdf;

  const PurchaseOrderItemCard({
    super.key,
    required this.order,
    this.supplier,
    required this.onTap,
    required this.onPrintPdf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final formattedDate =
        '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';
    final poNumber = order.poNumber.trim().isNotEmpty
        ? order.poNumber.trim()
        : '#${order.id.length > 8 ? order.id.substring(order.id.length - 6) : order.id}';

    final isPaid = order.dueAmount <= 0;
    final supplierDisplayName = order.supplierName.trim().isNotEmpty
        ? order.supplierName
        : (supplier?.name.trim().isNotEmpty == true ? supplier!.name : 'Supplier');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      elevation: 0,
      color: isDark ? colorScheme.surface : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Voucher No & Status Badge & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              poNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? (isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50)
                                : (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isPaid ? Colors.green.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : 'DUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Supplier Name & Company
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      supplierDisplayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.6),
              const SizedBox(height: 8),

              // Items List Breakdown
              if (order.items.isNotEmpty)
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${item.itemName.isNotEmpty ? item.itemName : "Product"} (x${item.quantity})',
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '৳${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'No product details recorded',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                  ),
                ),

              const SizedBox(height: 6),
              const Divider(height: 1, thickness: 0.6),
              const SizedBox(height: 8),

              // Financial Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ৳${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    order.dueAmount > 0
                        ? 'Due: ৳${order.dueAmount.toStringAsFixed(0)}'
                        : 'Paid in Full',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: order.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Action Buttons: View Receipt & PDF Print
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                      ),
                      onPressed: onTap,
                      icon: const Icon(Icons.receipt_long_outlined, size: 16),
                      label: const Text('View Details', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                      ),
                      onPressed: onPrintPdf,
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Print PDF', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
