import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import '../../../subscription/data/models/payment_model.dart';

class PaymentHistorySection extends StatelessWidget {
  final List<PaymentModel> payments;
  final bool isLoading;
  final VoidCallback onRefresh;

  const PaymentHistorySection({
    super.key,
    required this.payments,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Request History',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Refresh Payment History',
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (isLoading) ...[
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
        ] else if (payments.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No manual bKash/Nagad payment requests submitted yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Column(
            children: payments.map((payment) {
              final isApproved = payment.status.toLowerCase() == 'approved';
              final isRejected = payment.status.toLowerCase() == 'rejected';

              final Color statusColor = isApproved
                  ? Colors.green[700]!
                  : (isRejected ? Colors.red[700]! : Colors.orange[800]!);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TrxID: ${payment.transactionId}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              payment.status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Method: ${payment.method.toUpperCase()} | Tier: ${payment.targetTier.toUpperCase()}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            '${MoneyUtil.currencySymbol}${payment.amount.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
                          ),
                        ],
                      ),
                      if (isRejected && payment.rejectionReason != null && payment.rejectionReason!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Reason: ${payment.rejectionReason}',
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
