import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/widgets/global_warning_dialog.dart';
import '../../domain/entities/trash_item_entity.dart';

class TrashItemCard extends StatelessWidget {
  final TrashItemEntity item;
  final VoidCallback onRestore;
  final VoidCallback onPermanentDelete;

  const TrashItemCard({
    super.key,
    required this.item,
    required this.onRestore,
    required this.onPermanentDelete,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown Date';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  (IconData, Color, String) _getEntityTypeMetadata() {
    switch (item.entityType.toLowerCase()) {
      case 'item':
      case 'inventory':
        return (Icons.inventory_2_outlined, const Color(0xFF1565C0), 'Product Item');
      case 'customer':
        return (Icons.person_outline_rounded, const Color(0xFF2E7D32), 'Customer Profile');
      case 'sale':
        return (Icons.receipt_long_outlined, const Color(0xFF6A1B9A), 'Sales Invoice');
      case 'return':
        return (Icons.assignment_return_outlined, const Color(0xFFE65100), 'Sales Return');
      default:
        return (Icons.restore_from_trash_outlined, Colors.grey.shade700, 'Record');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (iconData, color, badgeLabel) = _getEntityTypeMetadata();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Entity Icon, Title, Badge & Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(iconData, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (item.amount != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${MoneyUtil.currencySymbol}${item.amount!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (item.subtitle.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                item.subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer: Deleted date, Restore & Permanent Delete Actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Deleted: ${_formatDate(item.deletedAt)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (item.deletedBy != null && item.deletedBy!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'By: ${item.deletedBy}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                OutlinedButton.icon(
                  onPressed: onRestore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade600),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmPermanentDelete(context),
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  tooltip: 'Permanently Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context) {
    GlobalWarningDialog.show(
      context,
      title: 'Permanent Hard Delete?',
      message: 'Are you sure you want to permanently purge "${item.title}" from MongoDB storage?\n\n⚠️ WARNING: This action is IRREVERSIBLE. Data cannot be recovered after permanent deletion.',
      confirmText: 'Purge Permanently',
      cancelText: 'Cancel',
      confirmColor: Colors.red.shade700,
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        onPermanentDelete();
      },
    );
  }
}
