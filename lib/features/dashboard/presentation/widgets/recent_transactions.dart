import 'package:flutter/material.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  static const transactions = [
    (
    'INV-2024-1058',
    '৳ 12,560',
    'Paid',
    Color(0xFF10B981),
    Icons.receipt_long_outlined,
    ),
    (
    'INV-2024-1057',
    '৳ 5,240',
    'Paid',
    Color(0xFF10B981),
    Icons.receipt_long_outlined,
    ),
    (
    'INV-2024-1056',
    '৳ 8,750',
    'Due',
    Color(0xFFF97316),
    Icons.receipt_long_outlined,
    ),
    (
    'INV-2024-1055',
    '৳ 3,200',
    'Paid',
    Color(0xFF10B981),
    Icons.receipt_long_outlined,
    ),
    (
    'INV-2024-1054',
    '৳ 2,980',
    'Return',
    Color(0xFFEF4444),
    Icons.assignment_return_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: theme.dividerColor
              .withValues(alpha: 0.5),
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          ...transactions.map(
                (transaction) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: transaction
                            .$4
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),

                      child: Icon(
                        transaction.$5,
                        color: transaction.$4,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.$1,
                            style: theme
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '24 May, 10:30 AM',
                            style: theme
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          transaction.$2,
                          style: theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          transaction.$3,
                          style: TextStyle(
                            color: transaction.$4,
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}