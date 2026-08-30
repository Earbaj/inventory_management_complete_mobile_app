import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data is ReportsLoadedState ? snapshot.data : InjectionContainer.reportsBloc.state;
        final logs = state is ReportsLoadedState ? state.invoiceLogs : [];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Transactions 🧾',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/reports'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              if (logs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No recent transactions recorded yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...logs.take(5).map((sale) {
                  final isDue = sale.dueAmount > 0;
                  final statusColor = isDue ? const Color(0xFFF97316) : const Color(0xFF10B981);
                  final statusLabel = isDue ? 'Due (${MoneyUtil.currencySymbol}${sale.dueAmount.toStringAsFixed(0)})' : 'Paid';
                  final customerName = sale.customer?.name.isNotEmpty == true ? sale.customer!.name : 'Walk-in Customer';
                  final dateStr = sale.createdAt.toString().split(' ').first;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt_long_outlined, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sale.invoiceNo.isNotEmpty ? sale.invoiceNo : 'INV-${sale.id.substring(0, 6)}',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$customerName • $dateStr',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${MoneyUtil.currencySymbol} ${sale.netTotal.toStringAsFixed(0)}',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              statusLabel,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}