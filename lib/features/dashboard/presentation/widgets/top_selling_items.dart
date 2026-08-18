import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';

import '../../../posbilling/domain/entities/sale_entity.dart';
import '../../../posbilling/domain/entities/cart_item_entity.dart';

class TopSellingItems extends StatelessWidget {
  const TopSellingItems({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<ReportsState>(
      stream: InjectionContainer.reportsBloc.stream,
      initialData: InjectionContainer.reportsBloc.state,
      builder: (context, reportsSnapshot) {
        final reportsState = reportsSnapshot.data is ReportsLoadedState ? reportsSnapshot.data : InjectionContainer.reportsBloc.state;
        final List<SaleEntity> logs = reportsState is ReportsLoadedState ? reportsState.invoiceLogs : [];

        // Aggregate item sales count across logs
        final Map<String, int> itemSalesCount = {};
        for (final SaleEntity sale in logs) {
          for (final CartItemEntity cartItem in sale.items) {
            final String itemName = cartItem.item.name;
            final int currentQty = itemSalesCount[itemName] ?? 0;
            itemSalesCount[itemName] = currentQty + cartItem.quantity;
          }
        }

        final sortedItems = itemSalesCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

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
                      'Top Selling Items 🏆',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/inventory'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (sortedItems.isNotEmpty)
                ...sortedItems.take(5).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.value}',
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text('Sold', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  );
                })
              else
                StreamBuilder<InventoryState>(
                  stream: InjectionContainer.inventoryBloc.stream,
                  initialData: InjectionContainer.inventoryBloc.state,
                  builder: (context, invSnapshot) {
                    final invState = invSnapshot.data is InventoryLoadedState ? invSnapshot.data : InjectionContainer.inventoryBloc.state;
                    final items = invState is InventoryLoadedState ? invState.items : [];

                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No items added yet.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return Column(
                      children: items.take(5).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                    Text('Stock: ${item.stockQuantity} ${item.unit}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text('৳ ${item.sellPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}