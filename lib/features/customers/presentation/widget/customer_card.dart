import 'package:flutter/material.dart';
import '../../customer.dart';
import 'customer_info.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatement;
  final VoidCallback? onCollectPayment;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onStatement,
    this.onCollectPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AVATAR
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(customer.name),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // CUSTOMER INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 15,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            customer.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (customer.address?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customer.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // MORE POPUP MENU
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'pay':
                      if (onCollectPayment != null) onCollectPayment!();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                    case 'statement':
                      onStatement();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: 'pay',
                      child: Row(
                        children: [
                          Icon(Icons.payments_outlined, color: Colors.green),
                          SizedBox(width: 10),
                          Text('Receive Payment', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'statement',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined),
                          SizedBox(width: 10),
                          Text('View Statement'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 11),

          // BALANCE & ACTIONS
          Row(
            children: [
              Expanded(
                child: CustomerInfo(
                  title: 'Opening Balance',
                  value: '৳ ${customer.openingBalance.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: CustomerInfo(
                  title: customer.isAdvanceCredit
                      ? 'Advance Credit'
                      : (customer.hasDue ? 'Current Due' : 'Balance'),
                  value: '৳ ${(customer.isAdvanceCredit ? customer.advanceCredit : customer.totalDue).toStringAsFixed(0)}',
                  valueColor: customer.isAdvanceCredit
                      ? Colors.green[700]
                      : (customer.hasDue ? Colors.orange[900] : Colors.grey),
                ),
              ),
              if (onCollectPayment != null && customer.hasDue) ...[
                FilledButton.icon(
                  onPressed: onCollectPayment,
                  icon: const Icon(Icons.payments_outlined, size: 16),
                  label: const Text('Pay Due'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              OutlinedButton.icon(
                onPressed: onStatement,
                icon: const Icon(Icons.receipt_long_outlined, size: 17),
                label: const Text('Statement'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}