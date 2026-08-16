import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management_complete/features/inventory/presentation/widget/summary_card.dart';

import '../view/inventory_screen.dart';

class InventorySummary
    extends StatelessWidget {

  final int totalItems;
  final int lowStock;
  final int outOfStock;

  final InventoryFilter selectedFilter;

  final ValueChanged<InventoryFilter>
  onFilterChanged;

  const InventorySummary({
    required this.totalItems,
    required this.lowStock,
    required this.outOfStock,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 108,

      child: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          8,
        ),

        scrollDirection:
        Axis.horizontal,

        children: [

          SummaryCard(
            title: 'Total Items',
            value: '$totalItems',
            icon: Icons.inventory_2_outlined,
            selected:
            selectedFilter ==
                InventoryFilter.all,
            onTap: () {
              onFilterChanged(
                InventoryFilter.all,
              );
            },
          ),

          const SizedBox(width: 10),

          SummaryCard(
            title: 'Low Stock',
            value: '$lowStock',
            icon: Icons.warning_amber_rounded,
            selected:
            selectedFilter ==
                InventoryFilter.lowStock,
            onTap: () {
              onFilterChanged(
                InventoryFilter.lowStock,
              );
            },
          ),

          const SizedBox(width: 10),

          SummaryCard(
            title: 'Out of Stock',
            value: '$outOfStock',
            icon: Icons.remove_shopping_cart_outlined,
            selected:
            selectedFilter ==
                InventoryFilter.outOfStock,
            onTap: () {
              onFilterChanged(
                InventoryFilter.outOfStock,
              );
            },
          ),
        ],
      ),
    );
  }
}