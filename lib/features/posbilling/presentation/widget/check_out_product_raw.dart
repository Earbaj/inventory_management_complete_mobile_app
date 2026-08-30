import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';

import '../../pos_product.dart';

class CheckoutProductRow
    extends StatelessWidget {
  final PosProduct product;
  final int quantity;

  final ValueChanged<int>
  onQuantityChanged;

  const CheckoutProductRow({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
            ),
          ),

          const SizedBox(width: 10),

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
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                Text(
                  '${MoneyUtil.currencySymbol} ${product.price.toStringAsFixed(0)}',
                  style: theme
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor,
              ),
              borderRadius:
              BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity:
                  VisualDensity.compact,
                  onPressed: () {
                    onQuantityChanged(
                      quantity - 1,
                    );
                  },
                  icon: const Icon(
                    Icons.remove,
                    size: 18,
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
                  visualDensity:
                  VisualDensity.compact,
                  onPressed: () {
                    onQuantityChanged(
                      quantity + 1,
                    );
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 18,
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