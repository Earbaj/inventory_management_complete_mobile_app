import 'package:flutter/material.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierItemCard extends StatelessWidget {
  final SupplierEntity supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupplierItemCard({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
              // 1. Header: Avatar, Name & Popup Action
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          supplier.companyName.isNotEmpty ? supplier.companyName : 'N/A',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (val) {
                      if (val == 'details') {
                        onTap();
                      } else if (val == 'edit') {
                        onEdit();
                      } else if (val == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'details', child: Text('Details')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 2. Contact Info (Phone & Address)
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    supplier.phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                  if (supplier.address.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        supplier.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 12),

              // 3. Total Purchases and Due Cards
              Row(
                children: [
                  // Total Purchases
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Purchases',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳${supplier.totalPurchases.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Due Amount
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: supplier.dueAmount > 0
                            ? (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                            : (isDark ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.green.shade50),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: supplier.dueAmount > 0 ? Colors.red.shade300 : Colors.green.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Amount',
                            style: TextStyle(
                              fontSize: 11,
                              color: supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳${supplier.dueAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: supplier.dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
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
