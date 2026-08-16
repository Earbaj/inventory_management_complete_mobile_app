import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_complete/features/returnandrestoke/presentation/widget/quantity_controll.dart';

import '../../return_models.dart';

class ReturnItemCard
    extends StatelessWidget {

  final InvoiceItem item;
  final int quantity;

  final ValueChanged<int>
  onQuantityChanged;

  const ReturnItemCard({
    required this.item,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final subtotal =
        item.price * quantity;

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(

        color:
        colorScheme.surface,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        border:
        Border.all(
          color:
          theme.dividerColor
              .withValues(
            alpha: 0.7,
          ),
        ),
      ),

      child: Column(
        children: [

          Row(
            children: [

              // ======================
              // PRODUCT ICON
              // ======================

              Container(
                width: 48,
                height: 48,

                decoration:
                BoxDecoration(
                  color: colorScheme
                      .primary
                      .withValues(
                    alpha: 0.08,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),

                child: Icon(
                  Icons.inventory_2_outlined,

                  color:
                  colorScheme.primary,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              // ======================
              // PRODUCT
              // ======================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      item.productName,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      'SKU: ${item.sku}',

                      style:
                      theme.textTheme
                          .bodySmall,
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '৳ ${item.price.toStringAsFixed(2)} / item',

                      style:
                      theme.textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          const Divider(
            height: 1,
          ),

          const SizedBox(
            height: 11,
          ),

          Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Purchased',

                      style:
                      theme.textTheme
                          .bodySmall,
                    ),

                    Text(
                      '${item.purchasedQuantity}',

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Available Return',

                      style:
                      theme.textTheme
                          .bodySmall,
                    ),

                    Text(
                      '${item.availableQuantity}',

                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.w700,

                        color:
                        item.availableQuantity >
                            0
                            ? colorScheme
                            .primary
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================
              // QUANTITY CONTROLLER
              // ======================

              QuantityController(
                quantity:
                quantity,

                max:
                item.availableQuantity,

                onChanged:
                onQuantityChanged,
              ),
            ],
          ),

          if (quantity > 0) ...[

            const SizedBox(
              height: 10,
            ),

            Align(
              alignment:
              Alignment.centerRight,

              child: Text(
                'Return: ৳ ${subtotal.toStringAsFixed(2)}',

                style:
                TextStyle(
                  fontWeight:
                  FontWeight.w800,

                  color:
                  colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}