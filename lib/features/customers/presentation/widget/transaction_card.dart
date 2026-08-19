import 'package:flutter/material.dart';
import '../../customer_transaction.dart';

class TransactionCard extends StatelessWidget {
  final CustomerTransaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSale = transaction.type == TransactionType.sale;
    final isPayment = transaction.type == TransactionType.payment;

    final Color iconColor;
    if (isSale) {
      iconColor = Colors.orange[800]!;
    } else if (isPayment) {
      iconColor = Colors.green[700]!;
    } else {
      iconColor = Colors.red[700]!;
    }

    final IconData icon;
    if (isSale) {
      icon = Icons.shopping_cart_outlined;
    } else if (isPayment) {
      icon = Icons.payments_outlined;
    } else {
      icon = Icons.assignment_return_outlined;
    }

    final String title;
    if (isSale) {
      title = 'Sale Invoice';
    } else if (isPayment) {
      title = 'Payment Received';
    } else {
      title = 'Product Return';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      transaction.reference,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(transaction.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '৳ ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                        fontSize: 15,
                      ),
                    ),
                    if (transaction.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.note,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}