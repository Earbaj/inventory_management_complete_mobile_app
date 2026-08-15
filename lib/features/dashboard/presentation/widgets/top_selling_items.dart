import 'package:flutter/material.dart';

class TopSellingItems extends StatelessWidget {
  const TopSellingItems({super.key});

  static const products = [
    ('Wireless Mouse', '320', Icons.mouse_outlined),
    ('USB Keyboard', '280', Icons.keyboard_outlined),
    ('HD Monitor 24"', '210', Icons.monitor_outlined),
    ('Office Chair', '145', Icons.chair_outlined),
    ('External HDD 1TB', '110', Icons.storage_outlined),
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
                  'Top Selling Items',
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

          const SizedBox(height: 6),

          ...products.map(
                (product) {
              return Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 7,
                ),

                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,

                      decoration: BoxDecoration(
                        color: theme
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),

                      child: Icon(
                        product.$3,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        product.$1,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.$2,
                          style: theme
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        Text(
                          'Sold',
                          style: theme
                              .textTheme
                              .bodySmall,
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