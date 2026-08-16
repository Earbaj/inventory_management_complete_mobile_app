import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../inventory_item.dart';
import 'inventory_item_details_sub_widgets.dart';

class InventoryItemCard
    extends StatelessWidget {

  final InventoryItem item;
  final VoidCallback onEdit;

  const InventoryItemCard({
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool outOfStock =
        item.isOutOfStock;

    final bool lowStock =
        item.isLowStock;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: colorScheme.surface,

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color: theme.dividerColor
              .withValues(alpha: 0.6),
        ),
      ),

      child: Column(
        children: [

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // PRODUCT ICON

              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerHighest,

                  borderRadius:
                  BorderRadius.circular(13),
                ),

                child: Icon(
                  Icons.inventory_2_outlined,
                  color:
                  colorScheme.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              // NAME / SKU

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: onEdit,
                          visualDensity:
                          VisualDensity.compact,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'SKU: ${item.sku}',
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [

                        StatusBadge(
                          text: item.category,
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        StatusBadge(
                          text: item.unit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(height: 1),

          const SizedBox(height: 11),

          // ============================
          // DETAILS
          // ============================

          Row(
            children: [

              Expanded(
                child: ItemDetail(
                  title: 'Stock',
                  value:
                  '${item.stockQuantity} ${item.unit}',
                  valueColor:
                  outOfStock
                      ? Colors.red
                      : lowStock
                      ? Colors.orange
                      : null,
                ),
              ),

              Expanded(
                child: ItemDetail(
                  title: 'Sell Price',
                  value:
                  '৳ ${item.retailSellPrice.toStringAsFixed(0)}',
                ),
              ),

              Expanded(
                child: ItemDetail(
                  title: 'Purchase',
                  value:
                  '৳ ${item.purchasePrice.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ============================
          // STOCK STATUS
          // ============================

          if (outOfStock)
            StockAlert(
              text: 'Out of stock',
              icon:
              Icons.remove_shopping_cart_outlined,
              isError: true,
            )
          else if (lowStock)
            StockAlert(
              text:
              'Low stock • Minimum ${item.lowStockQuantity}',
              icon:
              Icons.warning_amber_rounded,
              isError: false,
            ),
        ],
      ),
    );
  }
}