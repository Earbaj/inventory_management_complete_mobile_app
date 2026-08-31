import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../../core/widgets/global_empty_placeholder.dart';
import '../../reports_models.dart';
import 'receipt_dialog.dart';

class InvoiceLogsTab extends StatelessWidget {
  final List<InvoiceLog> invoices;
  final Function(InvoiceLog)? onDeleteInvoice;

  const InvoiceLogsTab({
    super.key,
    required this.invoices,
    this.onDeleteInvoice,
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

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const GlobalEmptyPlaceholder(
        title: 'No Invoice Logs Found',
        subtitle:
        'Try adjusting your search query or date range filter.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _InvoiceCard(
          invoice: invoice,
          formattedDate: _formatDate(invoice.date),
          onDelete: () => _confirmDelete(context, invoice),
          onViewReceipt: () => _showReceiptDialog(context, invoice),
        );
      },
    );
  }

  void _showReceiptDialog(BuildContext context, InvoiceLog invoice) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDialog(invoice: invoice),
    );
  }

  void _confirmDelete(BuildContext context, InvoiceLog invoice) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Delete Invoice'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete invoice "${invoice.invoiceNumber}" for ${invoice.customerName}?\n\n'
          'This will remove the invoice record from sales reports and move it to the Recycle Bin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Delete Invoice'),
            onPressed: () {
              Navigator.pop(dialogCtx);
              onDeleteInvoice?.call(invoice);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleting ${invoice.invoiceNumber}...'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceLog invoice;
  final String formattedDate;
  final VoidCallback onDelete;
  final VoidCallback onViewReceipt;

  const _InvoiceCard({
    required this.invoice,
    required this.formattedDate,
    required this.onDelete,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Invoice Number, Payment Status, Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Payment Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: invoice.paymentStatus.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice.paymentStatus.label,
                    style: TextStyle(
                      color: invoice.paymentStatus.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Middle Info: Customer Name, Served By, Due Amount, Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              invoice.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Served by: ${invoice.servedBy}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${MoneyUtil.currencySymbol}${invoice.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.dueAmount > 0
                          ? 'Due: ${MoneyUtil.currencySymbol}${invoice.dueAmount.toStringAsFixed(2)}'
                          : 'Paid Full',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: invoice.dueAmount > 0 ? Colors.red : Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Bottom Actions Row: PDF action & Delete action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${invoice.items.length} item(s)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onViewReceipt,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('Receipt PDF'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: Colors.red[600],
                      tooltip: 'Delete Invoice',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
