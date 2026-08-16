import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../pos_product.dart';

class ProductCard extends StatelessWidget {
  final PosProduct product;
  final int quantity;

  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // PRODUCT ICON

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // PRODUCT INFO

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'SKU: ${product.sku}',
                  style: theme
                      .textTheme
                      .bodySmall,
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Text(
                      '৳ ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color:
                        colorScheme.primary,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'Stock: ${product.stock}',
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ADD / QUANTITY

          if (quantity == 0)
            IconButton.filledTonal(
              onPressed: onAdd,
              icon: const Icon(
                Icons.add_rounded,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: colorScheme
                    .primary
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    visualDensity:
                    VisualDensity.compact,
                    icon: const Icon(
                      Icons.remove_rounded,
                    ),
                  ),

                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  IconButton(
                    onPressed: onAdd,
                    visualDensity:
                    VisualDensity.compact,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}