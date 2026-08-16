import 'package:flutter/material.dart';

import '../../../../core/route/app_route.dart';
import '../../inventory_item.dart';
import '../widget/inventory_add_item_bottom_sheet.dart';
import '../widget/inventory_empty_state.dart';
import '../widget/inventory_item_card.dart';
import '../widget/inventory_summery.dart';


enum InventoryFilter {
  all,
  lowStock,
  outOfStock,
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() =>
      _InventoryScreenState();
}

class _InventoryScreenState
    extends State<InventoryScreen> {

  final TextEditingController searchController =
  TextEditingController();

  final List<InventoryItem> items = [
    const InventoryItem(
      id: '1',
      name: 'Wireless Mouse',
      sku: 'WM-001',
      category: 'Accessories',
      unit: 'Piece',
      lowStockQuantity: 10,
      stockQuantity: 42,
      retailSellPrice: 850,
      purchasePrice: 650,
    ),

    const InventoryItem(
      id: '2',
      name: 'USB Keyboard',
      sku: 'KB-002',
      category: 'Accessories',
      unit: 'Piece',
      lowStockQuantity: 10,
      stockQuantity: 7,
      retailSellPrice: 1250,
      purchasePrice: 950,
    ),

    const InventoryItem(
      id: '3',
      name: 'HD Monitor 24"',
      sku: 'MN-003',
      category: 'Monitor',
      unit: 'Piece',
      lowStockQuantity: 5,
      stockQuantity: 0,
      retailSellPrice: 14500,
      purchasePrice: 12000,
    ),

    const InventoryItem(
      id: '4',
      name: 'Office Chair',
      sku: 'CH-004',
      category: 'Furniture',
      unit: 'Piece',
      lowStockQuantity: 5,
      stockQuantity: 8,
      retailSellPrice: 7800,
      purchasePrice: 6500,
    ),

    const InventoryItem(
      id: '5',
      name: 'External HDD 1TB',
      sku: 'HD-005',
      category: 'Storage',
      unit: 'Piece',
      lowStockQuantity: 5,
      stockQuantity: 15,
      retailSellPrice: 6200,
      purchasePrice: 5200,
    ),

    const InventoryItem(
      id: '6',
      name: 'USB-C Cable',
      sku: 'CB-006',
      category: 'Accessories',
      unit: 'Piece',
      lowStockQuantity: 15,
      stockQuantity: 9,
      retailSellPrice: 450,
      purchasePrice: 280,
    ),
  ];

  InventoryFilter selectedFilter =
      InventoryFilter.all;

  String selectedCategory = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<String> get categories {
    return [
      'All',
      ...items
          .map((item) => item.category)
          .toSet(),
    ];
  }

  List<InventoryItem> get filteredItems {
    final query =
    searchController.text.trim().toLowerCase();

    return items.where((item) {

      final matchesSearch =
          item.name.toLowerCase().contains(query) ||
              item.sku.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'All' ||
              item.category == selectedCategory;

      final matchesFilter =
      switch (selectedFilter) {
        InventoryFilter.all => true,

        InventoryFilter.lowStock =>
        item.isLowStock,

        InventoryFilter.outOfStock =>
        item.isOutOfStock,
      };

      return matchesSearch &&
          matchesCategory &&
          matchesFilter;
    }).toList();
  }

  int get lowStockCount {
    return items
        .where((item) => item.isLowStock)
        .length;
  }

  int get outOfStockCount {
    return items
        .where((item) => item.isOutOfStock)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            AppRoute.shellScaffoldKey.currentState?.openDrawer();
          },
          icon: const Icon(
            Icons.menu_rounded,
          ),
        ),

        title: const Text(
          'Inventory',
        ),

        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              // Search field already visible.
            },
            icon: const Icon(
              Icons.search_rounded,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddItemSheet();
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Item',
        ),
      ),

      body: Column(
        children: [

          // ============================
          // SUMMARY
          // ============================

          InventorySummary(
            totalItems: items.length,
            lowStock: lowStockCount,
            outOfStock: outOfStockCount,
            selectedFilter: selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),

          // ============================
          // SEARCH
          // ============================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              10,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                'Search item name, SKU or barcode',

                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),

                suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                )
                    : null,

                filled: true,

                fillColor: colorScheme
                    .surfaceContainerHighest,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ============================
          // CATEGORY
          // ============================

          SizedBox(
            height: 40,
            child: ListView.separated(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: 8),
              itemBuilder: (context, index) {

                final category =
                categories[index];

                final selected =
                    selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory =
                          category;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ============================
          // ITEM LIST
          // ============================

          Expanded(
            child: filteredItems.isEmpty
                ? const EmptyInventory()
                : ListView.builder(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                4,
                16,
                100,
              ),
              itemCount:
              filteredItems.length,
              itemBuilder:
                  (context, index) {

                final item =
                filteredItems[index];

                return InventoryItemCard(
                  item: item,
                  onEdit: () {
                    _openAddItemSheet(
                      existingItem: item,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ====================================
  // ADD / EDIT ITEM
  // ====================================

  void _openAddItemSheet({
    InventoryItem? existingItem,
  }) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {

        return AddItemSheet(
          existingItem: existingItem,

          onSave: (item) {

            setState(() {

              if (existingItem == null) {
                items.add(item);
              } else {

                final index = items.indexWhere(
                      (element) =>
                  element.id == item.id,
                );

                if (index != -1) {
                  items[index] = item;
                }
              }
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  existingItem == null
                      ? 'Item added successfully'
                      : 'Item updated successfully',
                ),
              ),
            );
          },
        );
      },
    );
  }
}