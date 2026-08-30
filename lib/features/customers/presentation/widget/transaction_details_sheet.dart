import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../customer_transaction.dart';
import '../../../returnandrestoke/domain/entities/return_item_entity.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final CustomerTransaction? statementTransaction;
  final SaleEntity? saleInvoice;
  final ReturnItemEntity? returnLog;

  const TransactionDetailsSheet({
    super.key,
    this.statementTransaction,
    this.saleInvoice,
    this.returnLog,
  });

  static void showForStatement(
    BuildContext context, {
    required CustomerTransaction transaction,
    List<SaleEntity>? customerSales,
  }) {
    // Attempt to match sale entity by reference or invoice number
    SaleEntity? matchedSale;
    if (transaction.type == TransactionType.sale && customerSales != null && customerSales.isNotEmpty) {
      final ref = transaction.reference.trim().toLowerCase();
      matchedSale = customerSales.firstWhere(
        (s) => s.invoiceNo.trim().toLowerCase() == ref || s.id.trim().toLowerCase() == ref,
        orElse: () => SaleEntity(
          id: '',
          invoiceNo: transaction.reference,
          items: const [],
          subtotal: transaction.amount,
          discountAmount: 0.0,
          vatAmount: 0.0,
          netTotal: transaction.amount,
          paidAmount: transaction.type == TransactionType.payment ? transaction.amount : 0.0,
          dueAmount: transaction.type == TransactionType.sale ? transaction.amount : 0.0,
          paymentMethod: 'cash',
          createdAt: transaction.date,
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionDetailsSheet(
        statementTransaction: transaction,
        saleInvoice: matchedSale,
      ),
    );
  }

  static void showForReturn(BuildContext context, ReturnItemEntity returnItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransactionDetailsSheet(
        returnLog: returnItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (returnLog != null) {
      return _buildReturnLogDetails(context, theme, colorScheme, returnLog!);
    }

    if (statementTransaction != null) {
      return _buildStatementDetails(context, theme, colorScheme, statementTransaction!);
    }

    return Container();
  }

  // ====================================================
  // 1. RETURN TRANSACTION DETAILS MODAL
  // ====================================================
  Widget _buildReturnLogDetails(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    ReturnItemEntity item,
  ) {
    final dateStr = '${item.createdAt.day.toString().padLeft(2, '0')}/'
        '${item.createdAt.month.toString().padLeft(2, '0')}/'
        '${item.createdAt.year} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Return Transaction Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Invoice: ${item.invoiceNo}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(height: 24),

          // SUMMARY CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDetailRow('Returned Item', item.itemName, isBold: true),
                const SizedBox(height: 8),
                _buildDetailRow('Customer Name', item.customerName ?? 'Walk-in Customer'),
                const SizedBox(height: 8),
                _buildDetailRow('Return Quantity', '${item.returnQuantity} units'),
                const SizedBox(height: 8),
                _buildDetailRow('Unit Price', '${MoneyUtil.currencySymbol} ${item.unitPrice.toStringAsFixed(2)}'),
                const Divider(height: 16),
                _buildDetailRow(
                  'Total Refund Amount',
                  '${MoneyUtil.currencySymbol} ${item.totalRefundAmount.toStringAsFixed(2)}',
                  isBold: true,
                  valueColor: Colors.red[700],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ADDITIONAL META DETAILS
          _buildDetailRow('Refund Method', item.refundMethod.toUpperCase(), isBold: true),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Inventory Restock',
            item.isRestocked ? 'Restocked (+${item.returnQuantity} Stock)' : 'Not Restocked',
            valueColor: item.isRestocked ? Colors.green[700] : Colors.orange[800],
          ),
          if (item.reason != null && item.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow('Reason', item.reason!),
          ],
          const SizedBox(height: 8),
          _buildDetailRow('Date & Time', dateStr),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Details'),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // 2. STATEMENT TRANSACTION DETAILS MODAL
  // ====================================================
  Widget _buildStatementDetails(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CustomerTransaction tx,
  ) {
    final isSale = tx.type == TransactionType.sale;
    final isPayment = tx.type == TransactionType.payment;
    final isOpening = tx.type == TransactionType.opening;

    final title = isOpening
        ? 'Opening Balance Details'
        : (isSale
            ? 'Sale Invoice Details'
            : (isPayment ? 'Payment Receipt Details' : 'Return Log Details'));
    final iconColor = isOpening
        ? Colors.blue[800]!
        : (isSale
            ? Colors.orange[800]!
            : (isPayment ? Colors.green[700]! : Colors.red[700]!));
    final icon = isOpening
        ? Icons.info_outline_rounded
        : (isSale
            ? Icons.receipt_long_rounded
            : (isPayment ? Icons.payments_rounded : Icons.replay_rounded));

    final dateStr = '${tx.date.day.toString().padLeft(2, '0')}/'
        '${tx.date.month.toString().padLeft(2, '0')}/'
        '${tx.date.year}';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Ref: ${tx.reference}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 24),

            // TRANSACTION AMOUNT BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Amount', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 2),
                      Text(
                        '${MoneyUtil.currencySymbol} ${tx.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: iconColor),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isOpening
                          ? 'OPENING'
                          : (isSale ? 'SALE' : (isPayment ? 'RECEIVED' : 'RETURN')),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ITEMS BREAKDOWN IF AVAILABLE
            if (saleInvoice != null && saleInvoice!.items.isNotEmpty && !isOpening) ...[
              const Text('Purchased Items Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: saleInvoice!.items.map((cartItem) {
                    final itemTotal = cartItem.quantity * cartItem.item.retailSellPrice;
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          '${cartItem.quantity}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${MoneyUtil.currencySymbol} ${cartItem.item.retailSellPrice.toStringAsFixed(0)} each'),
                      trailing: Text(
                        '${MoneyUtil.currencySymbol} ${itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // METADATA DETAILS
            _buildDetailRow('Transaction Date', dateStr),
            const SizedBox(height: 8),
            _buildDetailRow('Description / Note', tx.note.isNotEmpty ? tx.note : 'No notes available'),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Running Balance',
              tx.runningBalance < 0
                  ? '${MoneyUtil.currencySymbol} ${tx.runningBalance.abs().toStringAsFixed(2)} (Due)'
                  : (tx.runningBalance > 0
                      ? '${MoneyUtil.currencySymbol} ${tx.runningBalance.toStringAsFixed(2)} (Credit)'
                      : '${MoneyUtil.currencySymbol} 0.00'),
              isBold: true,
              valueColor: tx.runningBalance < 0 ? Colors.orange[800] : Colors.green[700],
            ),
            if (saleInvoice != null && !isOpening) ...[
              if (saleInvoice!.originalGrandTotal > 0) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Original Price', '${MoneyUtil.currencySymbol} ${saleInvoice!.originalGrandTotal.toStringAsFixed(2)}'),
              ],
              if (saleInvoice!.totalRefunded > 0 || saleInvoice!.isReturned != 'none') ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Returned Amount',
                  '${MoneyUtil.currencySymbol} ${saleInvoice!.totalRefunded.toStringAsFixed(2)} (${saleInvoice!.isReturned.replaceAll('_', ' ').toUpperCase()})',
                  valueColor: Colors.red[700],
                  isBold: true,
                ),
              ],
              const SizedBox(height: 8),
              _buildDetailRow(
                'Net Payable Total',
                '${MoneyUtil.currencySymbol} ${(saleInvoice!.netGrandTotal > 0 ? saleInvoice!.netGrandTotal : saleInvoice!.netTotal).toStringAsFixed(2)}',
                isBold: true,
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Paid Amount', '${MoneyUtil.currencySymbol} ${saleInvoice!.paidAmount.toStringAsFixed(2)}', valueColor: Colors.green[700]),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Due Amount',
                '${MoneyUtil.currencySymbol} ${saleInvoice!.dueAmount.toStringAsFixed(2)}',
                valueColor: saleInvoice!.dueAmount > 0 ? Colors.orange[800] : Colors.grey[700],
                isBold: saleInvoice!.dueAmount > 0,
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
