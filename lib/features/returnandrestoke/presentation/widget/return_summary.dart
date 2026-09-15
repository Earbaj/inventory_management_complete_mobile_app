import 'package:flutter/material.dart';
import '../../../../core/localization/localization_local.dart';
import '../../../../core/utils/money_util.dart';
import '../../return_models.dart';

class ReturnSummary extends StatelessWidget {
  final CustomerInvoice invoice;
  final Map<String, int> quantities;

  const ReturnSummary({
    super.key,
    required this.invoice,
    required this.quantities,
  });

  double get returnTotal {
    return invoice.items.fold(
      0,
      (total, item) {
        final quantity = quantities[item.productId] ?? 0;
        return total + item.price * quantity;
      },
    );
  }

  int get totalItems {
    return quantities.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ReturnsStrings.invoiceSummary.getString(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$totalItems item(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  ReturnsStrings.refundTotal.getString(context),
                ),
              ),
              Text(
                '${MoneyUtil.currencySymbol} ${returnTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            ReturnsStrings.restockSubtitle.getString(context),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}