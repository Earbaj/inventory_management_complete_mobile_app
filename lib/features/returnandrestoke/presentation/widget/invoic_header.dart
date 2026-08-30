import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/money_util.dart';

import '../../return_models.dart';

class InvoiceHeader
    extends StatelessWidget {

  final CustomerInvoice invoice;

  const InvoiceHeader({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {

    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(

      padding:
      const EdgeInsets.all(15),

      decoration:
      BoxDecoration(

        color:
        colorScheme.surface,

        borderRadius:
        BorderRadius.circular(16),

        border:
        Border.all(
          color:
          theme.dividerColor,
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 44,
            height: 44,

            decoration:
            BoxDecoration(
              color:
              colorScheme.primary
                  .withValues(
                alpha: 0.10,
              ),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              Icons.receipt_long,
              color:
              colorScheme.primary,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  invoice.invoiceNumber,

                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  _formatDate(
                    invoice.date,
                  ),

                  style:
                  theme.textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),

          Text(
            '${MoneyUtil.currencySymbol} ${invoice.total.toStringAsFixed(0)}',

            style:
            const TextStyle(
              fontWeight:
              FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(
      DateTime date,
      ) {

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}